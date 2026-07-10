FROM golang:1.26.2-alpine3.22 AS builder

WORKDIR /src
RUN apk add --no-cache git
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/chf ./cmd

FROM alpine:3.22.1

RUN apk add --no-cache ca-certificates tini
WORKDIR /free5gc
COPY --from=builder /out/chf ./chf
RUN addgroup -g 1000 free5gc && \
    adduser -D -u 1000 -G free5gc free5gc && \
    ln -s /free5gc/nrf-cert /free5gc/cert && \
    chown -R free5gc:free5gc /free5gc
USER 1000:1000

ENTRYPOINT ["/sbin/tini", "--", "./chf"]
