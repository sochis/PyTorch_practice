.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
export PYTHONPATH := $(shell pwd)

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

.PHONY: format
format: ## format python file by yapf
	yapf lib --recursive --in-place --verbose

.PHONY: lint
lint: ## check style with flake8
	pylint lib tests
	flake8 lib tests
	mypy lib

.PHONY: clean-requirements
clean-requirements: ## remove requirements.txt file
	rm -f requirements.txt requirements-tests.txt

.PHONY: compile-requirements
## compile requirements by requirements.in
compile-requirements: clean-requirements
	pip-compile -v --output-file requirements.txt requirements.in

.PHONY: sync-requirements
sync-requirements: ## sync requirements with requirements.txt
	pip-sync requirements.txt

.PHONY: requirements
## execute a series of requirements
requirements: clean-requirements compile-requirements sync-requirements