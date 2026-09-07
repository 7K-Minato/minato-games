# Build stage
FROM golang:1.27-alpine@sha256:cf6fca6641884b8433441b2b0652976f975e1d0fdd26d177eaaf8596087f3125 AS builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY games/cs2/agent/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w' -o agent .

# Final stage
FROM gcr.io/distroless/static:nonroot

COPY --from=builder /build/agent /usr/local/bin/agent

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/agent"]
