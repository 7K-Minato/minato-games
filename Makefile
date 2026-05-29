# Makefile for Minato Games

CHARTS_DIR := charts
CHARTS := $(filter-out $(CHARTS_DIR)/_library $(CHARTS_DIR)/_template,$(wildcard $(CHARTS_DIR)/*))

.PHONY: all
all: lint test

.PHONY: lint
lint:
	@echo "Linting all charts..."
	@for chart in $(CHARTS); do \
		echo "  $$chart"; \
		helm lint $$chart || exit 1; \
	done

.PHONY: test
test:
	@echo "Testing all charts..."
	@for chart in $(CHARTS); do \
		echo "  $$chart"; \
		helm unittest $$chart || exit 1; \
	done

.PHONY: test-chart
test-chart:
	@if [ -z "$(CHART)" ]; then \
		echo "Usage: make test-chart CHART=minecraft-paper"; \
		exit 1; \
	fi
	helm unittest $(CHARTS_DIR)/$(CHART)

.PHONY: template
template:
	@for chart in $(CHARTS); do \
		echo "=== $$chart ==="; \
		helm template test $$chart | head -50; \
		echo; \
	done

.PHONY: package
package:
	@mkdir -p dist
	@for chart in $(CHARTS); do \
		echo "Packaging $$chart..."; \
		helm package $$chart --destination dist/; \
	done

.PHONY: index
index:
	@helm repo index dist/ --url https://7k-group.github.io/minato-games

.PHONY: clean
clean:
	@rm -rf dist/

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  lint        - Lint all charts"
	@echo "  test        - Run unit tests for all charts"
	@echo "  test-chart  - Run unit tests for a specific chart (CHART=...)"
	@echo "  template    - Render templates for all charts"
	@echo "  package     - Package all charts"
	@echo "  index       - Generate Helm repo index"
	@echo "  clean       - Remove dist/ directory"
