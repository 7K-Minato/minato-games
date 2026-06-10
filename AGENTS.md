# AGENTS.md — Minato Games

This repo contains curated game configurations (Helm charts, Go agents, profiles) for the Minato Kubernetes platform.

## Repository Structure

```
games/<game>/
  chart/       # Helm chart: GameProfile + Fleet + optional resources
  agent/       # Go gRPC agent implementation
  profile/     # Raw GameProfile YAML + example GameServer

charts/_library/  # Shared Helm library chart (shared helpers + NetworkPolicy template)
templates/        # Backstage scaffolder skeleton (NOT Go code — Jinja2 templates)
```

## Daily Commands

```bash
# Charts
make lint              # lint all charts (library + all games)
make test              # test all charts (auto-patches local library dep)
make test-chart GAME=minecraft   # test one chart
make template          # render all charts for inspection

# Agents
make ci-agent GAME=minecraft     # full CI: build, vet, test, lint
make ci-agents         # run ci-agent for all games
make build-agent GAME=minecraft  # build single agent binary
make build-agents      # build all agent binaries

# Profiles
make validate-profiles # YAML syntax check all profiles
```

## Critical Context

### Helm Library Dependency Patching

Game charts declare the library as an OCI dependency in `Chart.yaml`:
```yaml
dependencies:
  - name: minato-games-library
    repository: "oci://harbor.7kgroup.org/7kminato/charts"
```

For local testing, `make test` and `make test-chart` temporarily rewrite this to `file://../../../charts/_library`, run `helm dependency build`, then restore the OCI URL. Do not manually edit `Chart.yaml` — the Makefile handles it.

**If you run `helm` commands manually**, you must do the same patching or charts will fail to find the library.

### Go Module Path

The minato dependency module path is `github.com/7k-minato/minato` (not `7k-group`). All agent imports must use this path. The root `go.mod` is shared across all agents.

Run `go mod tidy` after changing imports.

### golangci-lint

Config is in `.golangci.yml`. The `templates/` directory is excluded — it contains Backstage scaffolder skeleton files with Jinja2 syntax, not valid Go.

### Conventional Commits

All commits must follow Conventional Commits with a game scope:

```
fix(minecraft): correct default port
feat(cs2): add new env var
feat(palworld)!: breaking change description
```

Scopes: `library`, `cs2`, `minecraft`, `palworld`, `generic`, or the new game name.

### Release Process

**Do not manually bump `Chart.yaml` versions or edit `CHANGELOG.md`.** release-please owns these.

1. Merge Conventional Commits to `main`
2. release-please opens a Release PR per game
3. Merge the Release PR → tags and releases are auto-created
4. CD builds agent images and publishes charts to Harbor OCI registry

### Testing Agents Locally

The `make ci-agent` target runs the exact same steps as CI:
1. `go mod download`
2. `go build` (with `CGO_ENABLED=0 -ldflags='-s -w'`)
3. `go vet`
4. `go test`
5. `golangci-lint run`

Use this before pushing to catch issues without waiting for GitHub Actions.

### Adding a New Game

1. Create `games/<game>/{chart,agent,profile}/`
2. Add to `release-please-config.json` and `.release-please-manifest.json`
3. Run `make lint`, `make test`, `make ci-agent GAME=<game>`
4. Submit PR with Conventional Commits scoped to the game name

See `CONTRIBUTING.md` for full details.
