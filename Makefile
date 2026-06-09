# Makefile for Minato Games

GAMES_DIR := games
GAMES := $(notdir $(wildcard $(GAMES_DIR)/*))
CHARTS_DIR := charts

.PHONY: all
all: lint test

##@ Chart Operations

# Internal: patch game charts to use local library for CI/testing
.PHONY: _use-local-library
_use-local-library:
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/chart" ]; then \
			sed -i 's|repository: "oci://harbor.7kgroup.com/minato-games/charts"|repository: "file://../../../charts/_library"|' $(GAMES_DIR)/$$game/chart/Chart.yaml; \
			rm -f $(GAMES_DIR)/$$game/chart/Chart.lock $(GAMES_DIR)/$$game/chart/charts/minato-games-library-*.tgz; \
			helm dependency build $(GAMES_DIR)/$$game/chart || exit 1; \
		fi \
	done

# Internal: restore game charts to use OCI library
.PHONY: _use-oci-library
_use-oci-library:
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/chart" ]; then \
			sed -i 's|repository: "file://../../../charts/_library"|repository: "oci://harbor.7kgroup.com/minato-games/charts"|' $(GAMES_DIR)/$$game/chart/Chart.yaml; \
			rm -f $(GAMES_DIR)/$$game/chart/Chart.lock $(GAMES_DIR)/$$game/chart/charts/minato-games-library-*.tgz; \
		fi \
	done

.PHONY: lint
lint: ## Lint all charts.
	@echo "Linting library chart..."
	helm lint $(CHARTS_DIR)/_library || exit 1
	@echo "Linting game charts..."
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/chart" ]; then \
			echo "  $$game"; \
			helm lint $(GAMES_DIR)/$$game/chart || exit 1; \
		fi \
	done

.PHONY: test
test: ## Test all charts (uses local library).
	@echo "Patching charts to use local library..."
	@$(MAKE) _use-local-library
	@echo "Testing game charts..."
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/chart" ]; then \
			echo "  $$game"; \
			helm unittest $(GAMES_DIR)/$$game/chart || exit 1; \
		fi \
	done
	@echo "Restoring charts to use OCI library..."
	@$(MAKE) _use-oci-library

.PHONY: test-chart
test-chart: ## Test a specific chart (GAME=minecraft) using local library.
	@if [ -z "$(GAME)" ]; then \
		echo "Usage: make test-chart GAME=minecraft"; \
		exit 1; \
	fi
	@sed -i 's|repository: "oci://harbor.7kgroup.com/minato-games/charts"|repository: "file://../../../charts/_library"|' $(GAMES_DIR)/$(GAME)/chart/Chart.yaml
	@rm -f $(GAMES_DIR)/$(GAME)/chart/Chart.lock $(GAMES_DIR)/$(GAME)/chart/charts/minato-games-library-*.tgz
	@helm dependency build $(GAMES_DIR)/$(GAME)/chart || exit 1
	helm unittest $(GAMES_DIR)/$(GAME)/chart
	@sed -i 's|repository: "file://../../../charts/_library"|repository: "oci://harbor.7kgroup.com/minato-games/charts"|' $(GAMES_DIR)/$(GAME)/chart/Chart.yaml
	@rm -f $(GAMES_DIR)/$(GAME)/chart/Chart.lock $(GAMES_DIR)/$(GAME)/chart/charts/minato-games-library-*.tgz

.PHONY: template
template: ## Render templates for all game charts.
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/chart" ]; then \
			echo "=== $$game ==="; \
			helm template test $(GAMES_DIR)/$$game/chart | head -50; \
			echo; \
		fi \
	done

.PHONY: package
package: ## Package all charts.
	@mkdir -p dist
	@echo "Packaging library chart..."
	helm package $(CHARTS_DIR)/_library --destination dist/
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/chart" ]; then \
			echo "Packaging $$game chart..."; \
			helm package $(GAMES_DIR)/$$game/chart --destination dist/; \
		fi \
	done

.PHONY: index
index: ## Generate Helm repo index.
	@helm repo index dist/ --url https://7k-group.github.io/minato-games

##@ Agent Operations

.PHONY: ci-agent
ci-agent: ## Run all CI checks for a specific agent (GAME=minecraft).
	@if [ -z "$(GAME)" ]; then \
		echo "Usage: make ci-agent GAME=minecraft"; \
		exit 1; \
	fi
	@echo "=== Running CI for agent-$(GAME) ==="
	@echo "1. Downloading Go modules..."
	go mod download
	@echo "2. Building agent-$(GAME)..."
	@mkdir -p bin
	CGO_ENABLED=0 go build -ldflags='-s -w' -o bin/agent-$(GAME) ./$(GAMES_DIR)/$(GAME)/agent
	@echo "3. Running go vet..."
	go vet ./$(GAMES_DIR)/$(GAME)/agent/...
	@echo "4. Running tests..."
	go test ./$(GAMES_DIR)/$(GAME)/agent/...
	@echo "5. Running golangci-lint..."
	@which golangci-lint > /dev/null 2>&1 || (echo "    WARNING: golangci-lint not found. Install from https://golangci-lint.run/usage/install/" && exit 1)
	golangci-lint run ./$(GAMES_DIR)/$(GAME)/agent/...
	@echo "=== CI passed for agent-$(GAME) ==="

.PHONY: ci-agents
ci-agents: ## Run all CI checks for all agents.
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/agent" ]; then \
			$(MAKE) ci-agent GAME=$$game || exit 1; \
		fi \
	done

.PHONY: build-agents
build-agents: ## Build all game agent binaries.
	@mkdir -p bin
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/agent" ]; then \
			echo "Building agent-$$game..."; \
			CGO_ENABLED=0 go build -ldflags='-s -w' -o bin/agent-$$game ./$(GAMES_DIR)/$$game/agent || exit 1; \
		fi \
	done

.PHONY: build-agent
build-agent: ## Build a specific agent (GAME=minecraft).
	@if [ -z "$(GAME)" ]; then \
		echo "Usage: make build-agent GAME=minecraft"; \
		exit 1; \
	fi
	@mkdir -p bin
	CGO_ENABLED=0 go build -ldflags='-s -w' -o bin/agent-$(GAME) ./$(GAMES_DIR)/$(GAME)/agent

.PHONY: vet-agents
vet-agents: ## Run go vet on all agents.
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/agent" ]; then \
			echo "Vetting agent-$$game..."; \
			go vet ./$(GAMES_DIR)/$$game/agent/... || exit 1; \
		fi \
	done

.PHONY: test-agents
test-agents: ## Run tests for all agents.
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/agent" ]; then \
			echo "Testing agent-$$game..."; \
			go test ./$(GAMES_DIR)/$$game/agent/... || exit 1; \
		fi \
	done

##@ Profile Operations

.PHONY: validate-profiles
validate-profiles: ## Validate all GameProfile YAMLs.
	@for game in $(GAMES); do \
		if [ -d "$(GAMES_DIR)/$$game/profile" ]; then \
			echo "Validating $$game profiles..."; \
			for f in $(GAMES_DIR)/$$game/profile/*.yaml; do \
				python3 -c "import yaml; yaml.safe_load(open('$$f'))" || exit 1; \
			done; \
		fi \
	done

##@ Cleanup

.PHONY: clean
clean: ## Remove dist/ and bin/ directories.
	@rm -rf dist/ bin/

##@ Help

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\u003ctarget\u003e\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
