SHELL            := /usr/bin/env bash
ROOT             := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
STYLUAC          := $(ROOT)/.stylua.toml
SELENEC          := $(ROOT)/selene.toml

.PHONY: all check format format-check lint test benchmark contrib contrib-verify install-hooks help

all: format lint contrib

check: format-check lint test contrib-verify

test:
	@cache_dir="$$(mktemp -d)"; trap 'rm -rf "$$cache_dir"' EXIT; \
		cd "$(ROOT)" && XDG_CACHE_HOME="$$cache_dir" nvim --headless -u NONE -l "tests/headless.lua"

benchmark:
	@cache_dir="$$(mktemp -d)"; trap 'rm -rf "$$cache_dir"' EXIT; \
		cd "$(ROOT)" && XDG_CACHE_HOME="$$cache_dir" nvim --headless -u NONE -l "tests/benchmark.lua"

# Install git hooks
install-hooks:
	@git -C "$(ROOT)" config core.hooksPath .githooks

# Format all Lua files according to .stylua.toml
format:
	@stylua --config-path "$(STYLUAC)" "$(ROOT)"

# Check Lua formatting without changing files
format-check:
	@stylua --check --config-path "$(STYLUAC)" "$(ROOT)"

# Lint Lua files (scripts/ excluded: plain LuaJIT, no vim globals)
lint:
	@selene --config "$(SELENEC)" "$(ROOT)/lua" "$(ROOT)/colors" "$(ROOT)/plugin"

# Generate contrib/ theme files for external tools
contrib:
	@cd "$(ROOT)" && luajit scripts/gen_contrib.lua

# Verify contrib/ files are up to date
contrib-verify:
	@cd "$(ROOT)" && luajit scripts/gen_contrib.lua --verify

# Display available targets
help:
	@echo "Available targets:"
	@echo "  all            - Format, lint, and generate contrib files"
	@echo "  check          - Check formatting, lint, tests, and contrib files"
	@echo "  format         - Format Lua files with stylua"
	@echo "  format-check   - Check Lua formatting with stylua"
	@echo "  lint           - Lint Lua files with selene"
	@echo "  test           - Run dependency-free headless runtime and generator tests"
	@echo "  benchmark      - Report warm reload medians, group counts, and cache sizes"
	@echo "  contrib        - Generate contrib/ theme files"
	@echo "  contrib-verify - Check contrib/ files are up to date"
	@echo "  install-hooks  - Enable git pre-commit hook"
