# ${{ values.displayName }} Profile

This profile configures a ${{ values.displayName }} dedicated server.

## Game Details

- **Image**: `${{ values.gameImage }}`
- **Documentation**: TBD

## Agent

- **Image**: `${{ values.agentImage }}`
- **Version**: `${{ values.agentVersion }}`

## Configuration

The profile supports the following environment variables via `spec.env`:

${{ values.defaultEnv | dump }}

## Storage

- **Default Size**: `${{ values.storageSize }}`
- **Mount Path**: `${{ values.storageMountPath }}`
- **Access Mode**: ReadWriteOnce

## Ports

${{ values.ports | dump }}

## Actions

${{ values.actions | dump }}
