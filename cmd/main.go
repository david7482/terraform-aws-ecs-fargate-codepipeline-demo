package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/rs/zerolog"
)

var (
	BuildHash = "unknown"
	BuildTime = "unknown"
)

func main() {
	// Create root logger
	rootLogger := zerolog.New(os.Stdout).With().Timestamp().Logger()

	// Create root context
	rootCtx, rootCtxCancelFunc := context.WithCancel(context.Background())
	rootCtx = rootLogger.WithContext(rootCtx)

	// Run server
	wg := sync.WaitGroup{}
	wg.Add(1)
	runServer(rootCtx, &wg)

	// Listen to SIGTEM/SIGINT to close
	var gracefulStop = make(chan os.Signal, 1)
	signal.Notify(gracefulStop, syscall.SIGTERM, syscall.SIGINT)
	<-gracefulStop
	rootCtxCancelFunc()

	// Wait for all services to close with a specific timeout
	var waitUntilDone = make(chan struct{})
	go func() {
		wg.Wait()
		close(waitUntilDone)
	}()
	select {
	case <-waitUntilDone:
		rootLogger.Info().Msg("success to close all services")
	case <-time.After(10 * time.Second):
		rootLogger.Err(context.DeadlineExceeded).Msg("fail to close all services")
	}
}

func runServer(ctx context.Context, wg *sync.WaitGroup) {
	addr := "0.0.0.0:8080"

	router := http.NewServeMux()
	router.HandleFunc("/hash", buildhash)
	router.HandleFunc("/time", buildtime)

	server := &http.Server{
		Addr:    addr,
		Handler: router,
	}

	go func() {
		// Wait for ctx done
		<-ctx.Done()

		// Give 3 second to gracefully shutdown server
		zerolog.Ctx(ctx).Info().Msgf("HTTP service is closing")
		ctx2, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = server.Shutdown(ctx2)

		// Notify when server is closed
		zerolog.Ctx(ctx).Info().Msgf("HTTP service is closed")
		wg.Done()
	}()

	go func() {
		zerolog.Ctx(ctx).Info().Msgf("HTTP service is on %s", addr)
		err := server.ListenAndServe()
		if err != nil && err != http.ErrServerClosed {
			zerolog.Ctx(ctx).Panic().Err(err).Str("Addr", addr).Msg("Fail to start HTTP service")
		}
	}()
}
