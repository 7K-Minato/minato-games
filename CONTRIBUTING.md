# Contributing to Minato Games

Thank you for your interest in contributing! This repository contains curated Helm charts for game servers running on the Minato platform.

## Adding a New Game Chart

### Option 1: Use Backstage Template (Recommended)

Use the Minato Game Template in Backstage to scaffold a new game chart:

1. Navigate to Backstage Create
2. Select "Minato Game Chart"
3. Fill in game details (name, image, ports, etc.)
4. Submit to create a PR automatically

### Option 2: Manual

1. Copy `charts/_template` to `charts/<your-game>`
2. Edit `Chart.yaml`, `values.yaml`, and `README.md`
3. Update templates in `templates/` for your game's specific resources
4. Add tests in `tests/`
5. Update `release-please-config.json` to include the new chart
6. Update `.release-please-manifest.json` with initial version `"0.1.0"`
7. Run `make lint` and `make test`
8. Submit a PR

## Chart Standards

- Follow the [Helm Base Skill](../minato/.config/opencode/skills/helm-base/SKILL.md) security requirements
- All charts must have `values.schema.json`
- All charts must have unit tests
- GameProfile names must be unique across the repository
- Use the shared `_library` chart for common helpers
- Library dependency must use OCI registry: `oci://harbor.7kgroup.com/minato-games/charts`

## Testing

```bash
# Lint all charts
make lint

# Test all charts
make test

# Test a specific chart
make test-chart CHART=minecraft-paper
```

## Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) format.

### Scopes

| Scope | Chart | Example |
|-------|-------|---------|
| `library` | `charts/_library` | `feat(library): add new helper template` |
| `cs2` | `charts/cs2` | `fix(cs2): update default env vars` |
| `minecraft-paper` | `charts/minecraft-paper` | `feat(minecraft-paper): add new config option` |
| `palworld` | `charts/palworld` | `fix(palworld): correct resource limits` |

### Commit Types

| Type | Version Bump |
|------|-------------|
| `fix(<scope>):` | Patch (0.0.X) |
| `feat(<scope>):` | Minor (0.X.0) |
| `feat(<scope>)!:` or `BREAKING CHANGE:` | Major (X.0.0) |

### Examples

```
fix(cs2): correct default port mapping
feat(minecraft-paper): add mod support
feat(palworld)!: rename storage.path to storage.mountPath

BREAKING CHANGE: The storage.path value has been renamed to storage.mountPath.
```

## Release Process

Releases are fully automated via [release-please](https://github.com/googleapis/release-please):

1. Merge commits to `main` using Conventional Commits format with correct scope
2. release-please reads commits and opens a Release PR
3. When the Release PR is merged, release-please creates the Git tag and GitHub Release
4. The CD workflow publishes the released chart to Harbor OCI registry

**Do not manually edit `Chart.yaml` version fields or `CHANGELOG.md`.** release-please owns these files.
