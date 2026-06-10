# Contributing to Minato Games

Thank you for your interest in contributing! This repository contains curated game configurations (charts, agents, and profiles) for game servers running on the Minato platform.

## Adding a New Game

### Option 1: Use Backstage Template (Recommended)

Use the Minato Game Template in Backstage to scaffold a new game:

1. Navigate to Backstage Create
2. Select "Minato Game"
3. Fill in game details (name, image, ports, etc.)
4. Submit to create a PR automatically

### Option 2: Manual

1. Create `games/<your-game>/` directory
2. Add `chart/` with `Chart.yaml`, `values.yaml`, and templates
3. Add `agent/` with Go agent implementation and `Dockerfile`
4. Add `profile/` with `profile.yaml` and `gameserver-example.yaml`
5. Update `release-please-config.json` to include `games/<your-game>`
6. Update `.release-please-manifest.json` with initial version `"0.1.0"`
7. Run `make lint`, `make test`, and `make build-agents`
8. Submit a PR

## Game Standards

- Follow the [Helm Base Skill](../minato/.config/opencode/skills/helm-base/SKILL.md) security requirements
- All charts must have `values.schema.json`
- All charts must have unit tests
- GameProfile names must be unique across the repository
- Use the shared `_library` chart for common helpers
- Library dependency must use OCI registry: `oci://harbor.7kgroup.com/minato-games/charts`
- Agents must implement the Minato agent gRPC API
- Agents should be built with `CGO_ENABLED=0` and run as non-root

## Testing

```bash
# Lint all charts
make lint

# Test all charts
make test

# Test a specific chart
make test-chart GAME=minecraft

# Build all agents
make build-agents

# Build specific agent
make build-agent GAME=minecraft

# Validate all profiles
make validate-profiles
```

## Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) format.

### Scopes

| Scope | Game | Example |
|-------|------|---------|
| `library` | `charts/_library` | `feat(library): add new helper template` |
| `cs2` | `games/cs2` | `fix(cs2): update default env vars` |
| `minecraft` | `games/minecraft` | `feat(minecraft): add new config option` |
| `palworld` | `games/palworld` | `fix(palworld): correct resource limits` |

### Commit Types

| Type | Version Bump |
|------|-------------|
| `fix(<scope>):` | Patch (0.0.X) |
| `feat(<scope>):` | Minor (0.X.0) |
| `feat(<scope>)!:` or `BREAKING CHANGE:` | Major (X.0.0) |

### Examples

```
fix(cs2): correct default port mapping
feat(minecraft): add mod support
feat(palworld)!: rename storage.path to storage.mountPath

BREAKING CHANGE: The storage.path value has been renamed to storage.mountPath.
```

## Release Process

Releases are fully automated via [release-please](https://github.com/googleapis/release-please):

1. Merge commits to `main` using Conventional Commits format with correct scope
2. release-please reads commits and opens a Release PR per game
3. When the Release PR is merged, release-please creates the Git tag and GitHub Release
4. The CD workflow:
   - Builds and publishes the game agent image to GitHub Container Registry
   - Publishes the game chart to Harbor OCI registry

**Do not manually edit `Chart.yaml` version fields or `CHANGELOG.md`.** release-please owns these files.
