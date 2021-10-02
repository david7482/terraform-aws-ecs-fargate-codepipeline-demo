# build stage
FROM golang:1.17 as builder_go

COPY . /tmp/src
WORKDIR /tmp/src
RUN make build

# final stage
FROM debian:buster-slim

RUN apt-get update \
    && apt-get --no-install-recommends -y install \
    	ca-certificates \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder_go  /tmp/src/bin/demo /demo

CMD /demo