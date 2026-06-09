# Palworld

Palworld dedicated server Helm chart for Minato.

## Prerequisites

- Minato operator installed
- Kubernetes 1.28+

## Installing

```bash
helm install palworld minato-games/palworld \
  --namespace minato \
  --create-namespace \
  --set security.rcon.password=changeme
```

## Configuration

| Key | Description | Default |
|-----|-------------|---------|
| `game.env.PLAYERS` | Max players | `32` |
| `game.env.MULTITHREADING` | Enable multithreading | `true` |
| `game.env.UPDATE_ON_BOOT` | Update server on boot | `true` |
| `game.storage.size` | PVC size | `20Gi` |
| `fleet.enabled` | Enable fleet mode | `false` |
| `security.rcon.password` | RCON password | `""` |

## Actions

- `restart` — Restart the server
- `save-world` — Save the game world
- `broadcast` — Broadcast a message
- `kick-player` — Kick a player
- `ban-player` — Ban a player
