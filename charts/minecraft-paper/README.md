# Minecraft Paper

Minecraft Paper server Helm chart for Minato.

## Prerequisites

- Minato operator installed
- Kubernetes 1.28+

## Installing

```bash
helm install minecraft minato-games/minecraft-paper \
  --namespace minato \
  --create-namespace \
  --set security.rcon.password=changeme
```

## Configuration

See [values.yaml](values.yaml) for all options.

### Key Values

| Key | Description | Default |
|-----|-------------|---------|
| `game.env.EULA` | Accept Minecraft EULA | `"true"` |
| `game.env.VERSION` | Minecraft version | `"1.20.4"` |
| `game.env.MEMORY` | JVM memory limit | `"2G"` |
| `game.storage.size` | PVC size | `20Gi` |
| `fleet.enabled` | Enable fleet mode | `false` |
| `fleet.replicas` | Number of servers | `1` |
| `security.rcon.password` | RCON password | `""` |
| `monitoring.serviceMonitor.enabled` | Prometheus scraping | `false` |

## Actions

The following actions are available via the Minato control plane:

- `restart` — Gracefully restart the server
- `save-world` — Save the game world
- `send-message` — Broadcast a message
- `kick-player` — Kick a player
- `op-player` / `deop-player` — Manage operators
- `whitelist-add` / `whitelist-remove` — Manage whitelist
