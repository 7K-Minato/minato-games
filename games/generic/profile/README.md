# Generic Profile

This profile configures a game-agnostic agent using YAML-declared actions.

## Game Details

- **Image**: `gcr.io/distroless/static:nonroot`
- **Documentation**: https://github.com/7k-minato/minato

## Agent

- **Image**: `harbor.7kgroup.com/minato-games/minato-agent-generic:v0.1.0`
- **Version**: `0.1.0`

## Configuration

The generic agent supports declarative actions defined via environment variables or a config file. Actions are interpreted at runtime without game-specific code.

## Storage

- **Default Size**: `1Gi`
- **Mount Path**: `/data`
- **Access Mode**: ReadWriteOnce

## Ports

- **Agent**: `8080/TCP`

## Actions

- `noop`: No-op action for testing
