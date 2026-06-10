# Minato Games

Curated, production-ready game configurations for [Minato](https://github.com/7k-minato/minato) — the Kubernetes-native platform for persistent, multi-game dedicated game servers.

## What is this?

Each game in this repository is organized under `games/<game-name>/` and contains:

- **Chart** (`chart/`): Helm chart packaging a **GameProfile** (cluster-scoped game definition) plus optional **GameServerFleet** and supporting resources
- **Agent** (`agent/`): Go implementation of the Minato agent gRPC API for game-specific operations
- **Profile** (`profile/`): Raw GameProfile YAML and example GameServer manifests

## Prerequisites

- Kubernetes 1.28+ cluster
- [Minato operator](https://github.com/7k-minato/minato) installed (CRDs + operator + control plane)
- Helm 3.12+ with OCI support

## Quick Start

```bash
# Login to Harbor OCI registry
helm registry login harbor.7kgroup.com

# Install Minecraft
helm install minecraft oci://harbor.7kgroup.com/minato-games/charts/minecraft \
  --namespace minato \
  --create-namespace

# Check status
kubectl get gameserverfleet -n minato
kubectl get gameservers -n minato
```

## Available Games

| Game | Chart | Agent | Description | Status |
|------|-------|-------|-------------|--------|
| Minecraft | `minecraft` | Go | Minecraft Paper server with RCON | Production-ready |
| Counter-Strike 2 | `cs2` | Go | CS2 dedicated server | Production-ready |
| Palworld | `palworld` | Go | Palworld dedicated server | Production-ready |

## Game Structure

Each game follows a consistent structure:

```
games/<game>/
├── agent/
│   ├── main.go              # Agent gRPC implementation
│   └── Dockerfile           # Agent container image
├── chart/
│   ├── Chart.yaml           # Chart metadata
│   ├── values.yaml          # Default configuration
│   ├── values.schema.json   # JSON schema for validation
│   ├── README.md            # Game-specific documentation
│   ├── templates/
│   │   ├── gameprofile.yaml # GameProfile CR (cluster-scoped)
│   │   ├── fleet.yaml       # GameServerFleet CR (optional)
│   │   ├── networkpolicy.yaml # NetworkPolicies (optional)
│   │   ├── secret.yaml      # Secrets for passwords/tokens (optional)
│   │   ├── servicemonitor.yaml # Prometheus ServiceMonitor (optional)
│   │   └── NOTES.txt        # Post-install notes
│   └── tests/               # Helm unit tests
│       ├── gameprofile_test.yaml
│       ├── fleet_test.yaml
│       └── networkpolicy_test.yaml
└── profile/
    ├── profile.yaml         # GameProfile manifest
    ├── gameserver-example.yaml # Example GameServer
    └── README.md            # Profile documentation
```

## Common Configuration

All charts share these common values:

```yaml
# Game server configuration
game:
  env:
    # Game-specific environment variables
    EULA: "true"
  
  storage:
    size: 20Gi
    storageClass: ""  # Use cluster default
  
  resources:
    requests:
      cpu: 500m
      memory: 2Gi
    limits:
      cpu: 2
      memory: 4Gi

# Fleet configuration (optional)
fleet:
  enabled: false
  replicas: 1
  
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1

# Networking
networking:
  exposeMode: ClusterIP

# Security
security:
  networkPolicy:
    enabled: true
  
  # RCON password — set this!
  rcon:
    password: ""  # Required: set a strong password
    existingSecret: ""  # Or use an existing secret

# Monitoring
monitoring:
  serviceMonitor:
    enabled: false
    interval: 30s
```

## Multi-Tenancy

For hosting providers, deploy each tenant into a separate namespace:

```bash
# Tenant A
helm install minecraft-tenant-a oci://harbor.7kgroup.com/minato-games/charts/minecraft \
  --namespace tenant-a \
  --create-namespace \
  --set fleet.enabled=true \
  --set fleet.replicas=3

# Tenant B
helm install minecraft-tenant-b oci://harbor.7kgroup.com/minato-games/charts/minecraft \
  --namespace tenant-b \
  --create-namespace \
  --set fleet.enabled=true \
  --set fleet.replicas=5
```

## CI/CD

This repository uses centralized CI/CD workflows:

- **CI** (`.github/workflows/ci.yml`): Runs on PRs
  - Calls reusable workflows for Helm chart linting and testing
  - Builds and vets all game agents
  - Validates GameProfile YAMLs
- **CD** (`.github/workflows/cd.yml`): Runs on push to `main`
  - Uses release-please for automated versioning per game
  - Builds and publishes agent images to GitHub Container Registry
  - Publishes charts to Harbor OCI registry

### Release Process

1. Merge commits to `main` using [Conventional Commits](https://www.conventionalcommits.org/) with game-specific scope (e.g., `feat(minecraft): add new action`)
2. release-please opens a Release PR with version bumps and changelogs per game
3. Merge the Release PR to trigger agent image builds and chart publishing

## Adding a New Game

### Option 1: Backstage Template (Recommended)

Use the Minato Game Template in Backstage to scaffold a new game automatically with chart, agent, and profile.

### Option 2: Manual

See [CONTRIBUTING.md](CONTRIBUTING.md) for manual game creation instructions.

## Development

### Building Agents

```bash
# Build all agents
make build-agents

# Build specific agent
make build-agent GAME=minecraft
```

### Linting Charts

```bash
make lint
```

### Running Tests

```bash
# Test all charts
make test

# Test a specific chart
make test-chart GAME=minecraft

# Validate all profiles
make validate-profiles
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit conventions, release process, and game standards.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
