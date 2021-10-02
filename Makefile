all: build

GIT_REV=$(shell git rev-parse HEAD | cut -c1-7)
BUILD_DATE=$(shell date -u +%Y-%m-%d.%H:%M:%S)
EXTRA_LD_FLAGS=-X main.BuildHash=${GIT_REV} -X main.BuildTime=${BUILD_DATE}

# Setup test packages
TEST_PACKAGES = ./cmd/...

test:
	go vet $(TEST_PACKAGES)
	go test -race -cover -coverprofile cover.out $(TEST_PACKAGES)
	go tool cover -func=cover.out | tail -n 1 | awk '{print $3}'

build:
	go build -ldflags "-s -w -extldflags \"-v\" ${EXTRA_LD_FLAGS}" -o bin/demo ./cmd/

run: build
	./bin/demo