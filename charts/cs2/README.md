# Counter-Strike 2

CS2 dedicated server Helm chart for Minato.

## Prerequisites

- Minato operator installed
- Steam Game Server Login Token (GSLT)

## Installing

```bash
helm install cs2 minato-games/cs2 \
  --namespace minato \
  --create-namespace \
  --set game.env.SRCDS_TOKEN=your-steam-token \
  --set security.rcon.password=changeme
```

## Configuration

| Key | Description | Default |
|-----|-------------|---------|
| `game.env.SRCDS_TOKEN` | Steam GSLT (required) | `""` |
| `game.env.SRCDS_MAXPLAYERS` | Max players | `64` |
| `game.env.SRCDS_TICKRATE` | Server tickrate | `128` |
| `game.env.SRCDS_STARTMAP` | Starting map | `de_dust2` |
| `game.storage.size` | PVC size | `50Gi` |
| `fleet.enabled` | Enable fleet mode | `false` |
| `security.rcon.password` | RCON password | `""` |

## Actions

- `restart` — Restart the server
- `change-map` — Change map
- `kick-player` — Kick by Steam ID
- `ban-player` — Ban by Steam ID
- `say` — Broadcast message
