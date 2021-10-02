package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"
)

func Test_buildhash(t *testing.T) {
	BuildHash = "12345"

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	res := httptest.NewRecorder()

	buildhash(res, req)

	require.EqualValues(t, http.StatusOK, res.Code)

	body, _ := io.ReadAll(res.Body)
	require.JSONEq(t, `{"buildhash":"12345"}`, string(body))
}

func Test_buildtime(t *testing.T) {
	BuildTime = "12345"

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	res := httptest.NewRecorder()

	buildtime(res, req)

	require.EqualValues(t, http.StatusOK, res.Code)

	body, _ := io.ReadAll(res.Body)
	require.JSONEq(t, `{"buildtime":"12345"}`, string(body))
}
