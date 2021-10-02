package main

import (
	"encoding/json"
	"net/http"
)

func buildhash(writer http.ResponseWriter, request *http.Request) {
	writer.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(writer).Encode(map[string]string{
		"buildhash": BuildHash,
	})
}

func buildtime(writer http.ResponseWriter, request *http.Request) {
	writer.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(writer).Encode(map[string]string{
		"buildtime": BuildTime,
	})
}
