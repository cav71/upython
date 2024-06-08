# Windows:
#   1. Install MSYS2 from https://www.msys2.org
#   2a. (cmd.exe) SET PATH=%PATH%;C:\msys64\usr\bin;C:\msys64
#   2b. (powershell) $env:Path += "C:\msys64\usr\bin;C:\msys64"
#   3. to install make: pacmman -S make

# self-documentation magic
help: ## Display the list of available targets
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: lint
x:  ## Runs the linter (mypy) and report errors.
	@echo "make {target}"

