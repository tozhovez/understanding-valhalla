#
#   Makefile
#
.PHONY: all

-include Makefile.include

PROJECT_NAME=understanding-valhalla
PWD := $(shell pwd)
LAST_COMMIT_SHA := $(shell git log -1 --pretty=format:%h -- .)
VERSION := $(shell cat .version)
EXPORT_VERSION := $(VERSION)
PACKAGE_NAME := $(shell basename "$(PWD)")
PYTHON := $(shell which python)
PIP := $(shell which pip)
PYV := $(shell $(PYTHON) -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)")
PROJECT_STORAGE := ${HOME}/${PACKAGE_NAME}/data-storage

BUILD_VERSION := latest
REQ_FILE_DEV := requirements-dev.txt
REQ_FILE_TOOLS := requirements-tools.txt


SHELL:= /bin/bash
dockerfile=Dockerfile

.DEFAULT_GOAL:  help

help: ## Show this help
	@printf "\n\033[33m%s:\033[1m\n" 'Choose available commands run in "$(PROJECT_NAME)"'
	@echo "===================================================================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-14s		\033[35;1m-- %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\033[33m%s\033[1m\n"
	@echo "===================================================================="


envs: help ## envs - display envs
	@echo "===================================================================="
	@echo  "EXPORT_VERSION: $(EXPORT_VERSION)"
	@echo  "LAST_COMMIT_SHA $(LAST_COMMIT_SHA)"
	@echo  "REQ_FILE_DEV: $(REQ_FILE_DEV)"
	@echo  "REQ_FILE_TOOLS: $(REQ_FILE_TOOLS)"
	@echo  "PYV: $(PYV)"
	@echo  "VERSION: $(VERSION)"
	@echo  "shell $(SHELL)"
	@echo  "pwd $(PWD)"
	@echo "PROJECT_NAME $(PROJECT_NAME)"
	@echo "PACKAGE_NAME $(PACKAGE_NAME)"
	@echo "PYTHON $(PYTHON)"
	@echo "PIP $(PIP)"
	@echo "PROJECT_STORAGE $(PROJECT_STORAGE)"
	@echo "===================================================================="
 


install-requirements: clean ## Install requirements
	@echo "===================================================================="
	@echo "install- $(REQ_FILE_DEV) requirements $(PYV) $(PACKAGE)"
	@echo "===================================================================="
	$(PIP) install --upgrade pip
	$(PIP) install -r $(REQ_FILE_DEV)
	@echo "===================================================================="


tools-requirements: help  ## Install tools requirements
	@echo "===================================================================="
	@echo "install $(REQ_FILE_TOOLS) for$(PYV) $(PACKAGE_NAME)"
	@echo "===================================================================="
	@$(PIP) install --upgrade pip
	@$(PIP) install --upgrade -r $(REQ_FILE_TOOLS)
	@echo "===================================================================="


run-infra: ## Run-infra (pull and run consul, redis, adminer, postgres dockers)
	@docker-compose -f docker-compose.infra.yml up -d> /dev/null



stop-infra: ## Stop-infra (consul, redis, adminer, postgres dockers)
	@docker-compose -f docker-compose.infra.yml down>/dev/null



create-database: ## Create postgres database and import schema
	@$(PYTHON) ./Infra/scripts/create_database.py



set-configs: ## set configs
	@echo "===================================================================="
	@chmod +x -R ./Infra
	@$(PYTHON) ./Infra/scripts/set_consul_configs.py



run-services:
	@docker-compose -f docker-compose.dev.yml -f docker-compose.debug.yml up -d --build>/dev/null

stop-services:
	@docker-compose -f docker-compose.dev.yml -f docker-compose.debug.yml down>/dev/null


flake8:
	@echo "===================================================================="
	@echo flake8 $(PACKAGE)
	@echo "===================================================================="
	flake8 --ignore=F401,E265,E129


.PHONY: clean-pyc clean-build clean-test clean

clean: clean-pyc clean-build clean-test clean-docs
	
clean-pyc: ## clean-pyc - remove Python file artifacts
	@echo "===================================================================="
	@echo "clean-pyc - remove Python file artifacts in $(PACKAGE_NAME)"
	@echo "===================================================================="
	rm -rf __pycache__ venv "*.pyc"
	find ./* -maxdepth 0 -name "*.pyc" -type f -delete
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-build: ## clean-build - remove build artifacts
	@echo "===================================================================="
	@echo "clean-build - remove build artifacts in $(PACKAGE_NAME)"
	@echo "===================================================================="
	rm -fr build/
	rm -fr dist/
	rm -fr **.egg-info/
	rm -fr .eggs/

clean-test: ## clean-test - remove test artifacts
	@echo "===================================================================="
	@echo "clean-test - remove test artifacts in $(PACKAGE_NAME)"
	@echo "===================================================================="
	rm -rf .tox/

clean-docs: ## clean-docs - remove documentation artifacts
	@echo "===================================================================="
	@echo "clean-docs - remove documentation artifacts"
	@echo "===================================================================="
	rm -rf docs/_build



list: ## Makefile target list
	@echo "===================================================================="
	@echo Makefile target list
	@echo "===================================================================="
	@cat Makefile | grep "^[a-z]" | awk '{print $$1}' | sed "s/://g" | sort