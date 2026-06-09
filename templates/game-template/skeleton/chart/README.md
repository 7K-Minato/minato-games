# ${{ values.displayName }}

${{ values.description }}

## Prerequisites

- Kubernetes 1.28+ cluster
- [Minato operator](https://github.com/7k-minato/minato) installed
- Helm 3.12+

## Installation

```bash
helm repo add minato-games https://7k-group.github.io/minato-games
helm repo update

helm install ${{ values.gameName }} minato-games/${{ values.gameName }} \\
  --namespace minato \\
  --create-namespace
```

## Configuration

See [values.yaml](values.yaml) for all available options.

## Development

### Linting

```bash
helm lint charts/${{ values.gameName }}
```

### Testing

```bash
helm unittest charts/${{ values.gameName }}
```
