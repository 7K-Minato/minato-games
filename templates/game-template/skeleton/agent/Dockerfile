# Build stage
FROM golang:1.26-alpine@sha256:87c65a688975c0b1d4585d204874c45ca78354670e3a5f11368c5a492303d696 AS builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY games/${{ values.gameName }}/agent/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w' -o agent .

# Final stage
FROM gcr.io/distroless/static:nonroot@sha256:25ac8f0c3b2334a9eb05452266bd4697864a8c8ef0ef71e5e6480d7f92868329

COPY --from=builder /build/agent /usr/local/bin/agent

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/agent"]
