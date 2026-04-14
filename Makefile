SHELL            := /usr/bin/env bash
ROOT             := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
STYLUAC          := $(ROOT)/.stylua.toml
SELENEC          := $(ROOT)/selene.toml

.PHONY: all format lint contrib contrib-verify install-hooks help

all: format lint contrib

# Install git hooks
install-hooks:
	@git config core.hooksPath .githooks

# Format all Lua files according to .stylua.toml
format:
	@stylua --config-path "$(STYLUAC)" "$(ROOT)"

# Lint Lua files (scripts/ excluded: plain LuaJIT, no vim globals)
lint:
	@selene --config "$(SELENEC)" "$(ROOT)/lua" "$(ROOT)/colors" "$(ROOT)/plugin"

# Generate contrib/ theme files for external tools
contrib:
	@luajit "$(ROOT)/scripts/gen_contrib.lua"

# Verify contrib/ files are up to date
contrib-verify:
	@luajit "$(ROOT)/scripts/gen_contrib.lua" --verify

# Display available targets
help:
	@echo "Available targets:"
	@echo "  all            - Format, lint, and verify contrib files"
	@echo "  format         - Format Lua files with stylua"
	@echo "  lint           - Lint Lua files with selene"
	@echo "  contrib        - Generate contrib/ theme files"
	@echo "  contrib-verify - Check contrib/ files are up to date"
	@echo "  install-hooks  - Enable git pre-commit hook"
