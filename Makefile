.PHONY: help
help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([A-Za-z0-9/_-]+):.+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

.PHONY: pre-commit
pre-commit:  ## Run pre-commit (optional: HOOK=example)
	pre-commit run --all-files --verbose --show-diff-on-failure --color always $(HOOK)

.PHONY: fmt
fmt:  ## Format HCL files
	terragrunt hclfmt

.PHONY: clean-cache
clean-cache: DIR ?= .
clean-cache:  ## Remove cache-related files (optional: DIR=example/directory/)
	find $(DIR) -type d \( -name '.terragrunt-cache' -o -name '.terraform' \) -print -prune -exec rm -rf '{}' \;
