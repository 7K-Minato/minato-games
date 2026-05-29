# Minato Games

Curated, production-ready Helm charts for deploying game servers on [Minato](https://github.com/7k-group/minato) — the Kubernetes-native platform for persistent, multi-game dedicated game servers.

## What is this?

Each chart in this repository packages a **GameProfile** (cluster-scoped game definition) plus optional **GameServerFleet** and supporting resources (NetworkPolicies, ConfigMaps, Secrets) for a specific game. Install a chart, get a running game server fleet.

## Prerequisites

- Kubernetes 1.28+ cluster
- [Minato operator](https://github.com/7k-group/minato) installed (CRDs + operator + control plane)
- Helm 3.12+ with OCI support

## Quick Start

```bash
# Login to Harbor OCI registry
helm registry login harbor.7kgroup.com

# Install Minecraft Paper
helm install minecraft oci://harbor.7kgroup.com/minato-games/charts/minecraft-paper \\
  --namespace minato \\
  --create-namespace

# Check status
kubectl get gameserverfleet -n minato
kubectl get gameservers -n minato
```

## Available Games

| Game | Chart | Description | Status |
|------|-------|-------------|--------|
| Minecraft Paper | `minecraft-paper` | Minecraft Paper server with RCON | Production-ready |
| Counter-Strike 2 | `cs2` | CS2 dedicated server | Production-ready |
| Palworld | `palworld` | Palworld dedicated server | Production-ready |

## Chart Structure

Each game chart follows a consistent structure:

```
charts/<game>/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration
├── values.schema.json      # JSON schema for validation
├── README.md               # Game-specific documentation
├── templates/
│   ├── gameprofile.yaml    # GameProfile CR (cluster-scoped)
│   ├── fleet.yaml          # GameServerFleet CR (optional)
│   ├── networkpolicy.yaml  # NetworkPolicies (optional)
│   ├── secret.yaml         # Secrets for passwords/tokens (optional)
│   ├── servicemonitor.yaml # Prometheus ServiceMonitor (optional)
│   └── NOTES.txt           # Post-install notes
└── tests/                  # Helm unit tests
    ├── gameprofile_test.yaml
    ├── fleet_test.yaml
    └── networkpolicy_test.yaml
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
helm install minecraft-tenant-a oci://harbor.7kgroup.com/minato-games/charts/minecraft-paper \\
  --namespace tenant-a \\
  --create-namespace \\
  --set fleet.enabled=true \\
  --set fleet.replicas=3

# Tenant B
helm install minecraft-tenant-b oci://harbor.7kgroup.com/minato-games/charts/minecraft-paper \\
  --namespace tenant-b \\
  --create-namespace \\
  --set fleet.enabled=true \\
  --set fleet.replicas=5
```

## CI/CD

This repository uses centralized CI/CD workflows:

- **CI** (`.github/workflows/ci.yml`): Runs on PRs, calls reusable workflows from [7K-Hiroba/workflows-library](https://github.com/7K-Hiroba/workflows-library) for lint, template, unittest, and kubeconform validation
- **CD** (`.github/workflows/cd.yml`): Runs on push to `main`, uses release-please for automated versioning and publishes charts to Harbor OCI registry

### Release Process

1. Merge commits to `main` using [Conventional Commits](https://www.conventionalcommits.org/) with game-specific scope
2. release-please opens a Release PR with version bumps and changelogs
3. Merge the Release PR to trigger chart publishing

## Adding a New Game

### Option 1: Backstage Template (Recommended)

Use the Minato Game Template in Backstage to scaffold a new game chart automatically.

### Option 2: Manual

See [CONTRIBUTING.md](CONTRIBUTING.md) for manual chart creation instructions.

## Development

### Linting Charts

```bash
make lint
```

### Running Tests

```bash
make test

# Test a specific chart
make test-chart CHART=minecraft-paper
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit conventions, release process, and chart standards.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
