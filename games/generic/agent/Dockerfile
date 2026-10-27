# Build stage
FROM golang:1.26-alpine@sha256:a2012b4a1d1f9f7e9f44e0d39b805a901e856b1dd80b4e6ee4338db547050308 AS builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY games/generic/agent/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w' -o agent .

# Final stage
FROM gcr.io/distroless/static:nonroot@sha256:18f4cc26c9ffa7f20a359298be7deadac5c607c8e03a02b8119f1a5fc2f82c99

COPY --from=builder /build/agent /usr/local/bin/agent

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/agent"]
