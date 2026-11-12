# Build stage
FROM golang:1.26-alpine@sha256:30b1e546a9c7fa3b747c2bdba3a0c7bdf3a02ebb4c5b8405d2f948d7e8aac4ec AS builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY games/${{ values.gameName }}/agent/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w' -o agent .

# Final stage
FROM gcr.io/distroless/static:nonroot@sha256:aafe993665bf6200db38a02c11a9351e782a84b6a45e7f33b6695638c88e3931

COPY --from=builder /build/agent /usr/local/bin/agent

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/agent"]
