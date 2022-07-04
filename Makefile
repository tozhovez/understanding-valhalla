#
#   Makefile
#
.PHONY: all

-include Makefile.include

PROJECT_NAME=understanding-valhalla
PWD := $(shell pwd)
LAST_COMMIT_SHA := $(shell git log -1 --pretty=format:%h -- .)
EXPORT_VERSION := $(VERSION)
PACKAGE_NAME := $(shell basename "$(PWD)")
PYTHON := $(shell which python)
PIP := $(shell which pip)
PYV := $(shell $(PYTHON) -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)")
AWS_CLI := $(shell which aws)
PROJECT_STORAGE := ${HOME}/${PROJECT_NAME}/data-storage
PACKAGE_STORAGE := ${HOME}/${PROJECT_NAME}/data-storage/${PACKAGE_NAME}
BUILD_VERSION := latest
ENV_CONFIGS := $(shell cat configs)
MODULE_NAME := valhalla-data
PACKAGE := valhalla-data
PACKAGE_PREFIX := valhalla-data
REQ_FILE := requirements.txt
REQ_FILE_TOOLS := requirements-tools.txt


SHELL:= /bin/bash
dockerfile=Dockerfile

module_name = $(MODULE_NAME)
#EXPORT_VERSION = $(eval VERSION=$(shell cat .version))


.DEFAULT_GOAL: help envs

help: ## Show this help
	@printf "\n\033[33m%s:\033[1m\n" 'Choose available CLI commands run "$(PROJECT_NAME)"'
	@echo "======================================================"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-14s		\033[35;1m-- %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\033[33m%s\033[1m\n"
	@echo "======================================================"


envs: ## envs - display envs
	@echo "======================================================"
	@echo  "STORAGE: $(STORAGE)"
	@echo  "MODULE_NAME: $(MODULE_NAME)"
	@echo  "PACKAGE: $(PACKAGE)"
	@echo  "PACKAGE_PREFIX: $(PACKAGE_PREFIX)"
	@echo  "REQ_FILE: $(REQ_FILE)"
	@echo  "$(REQ_FILE_TOOLS)"
	@echo  "PYV3: $(PYV3)"
	@echo  "EXPORT_VERSION: $(EXPORT_VERSION)"
	@echo  "package $(PACKAGE)"
	@echo  "shell $(SHELL)"
	@echo  "python $(PYTHON3)"
	@echo  "pwd $(PWD)"
	@echo "PROJECT_NAME $(PROJECT_NAME)"
	@echo "LAST_COMMIT_SHA $(LAST_COMMIT_SHA)"
	@echo "EXPORT_VERSION $(EXPORT_VERSION)" 
	@echo "PACKAGE_NAME $(PACKAGE_NAME)"
	@echo "PYTHON $(PYTHON)"
	@echo "PIP $(PIP)"
	@echo "AWS_CLI $(AWS_CLI)"
	@echo "VERSION $(VERSION)"
	@echo "PROJECT_STORAGE $(PROJECT_STORAGE)"
	@echo "PACKAGE_STORAGE $(PACKAGE_STORAGE)"
	@echo "ENV_CONFIGS $(ENV_CONFIGS)"
	@echo "======================================================"
 


install-requirements: clean ## Install requirements
	@echo "======================================================"
	@echo "install-requirements $(PYV3) $(PACKAGE)"
	@echo "======================================================"
	$(PIP) install --upgrade pip
	$(PIP) install -r $(REQ_FILE)
	@echo "======================================================"


tools-requirements: $(REQ_FILE_TOOLS)
	@echo "======================================================"
	@echo "tools-requirements $(PYV3)"
	@echo "======================================================"
	$(PIP) install --upgrade -r $(REQ_FILE_TOOLS)

run-infra: ## Run-infra (pull and run consul, postgres dockers)
	@docker-compose -f docker-compose.infra.yml up -d> /dev/null

stop-infra: ## Stop-infra (postgres dockers)
	@docker-compose -f docker-compose.infra.yml down>/dev/null

create-database: ## install-requirements run-infra ## Create postgres database and import schema
	@$(PYTHON) ./Infra/scripts/create_database.py


load-data: ## Load data
	@$(PYTHON) ./LoadData/main.py


update-data: ## Update_data
	@$(PYTHON) ./UpdaterService/main.py


stop-services: ##-f docker-compose.dev.yml -f docker-compose.debug.yml
	@docker-compose -f docker-compose.infra.yml  down>/dev/null

#run-services:
#	@docker-compose -f docker-compose.dev.yml -f docker-compose.debug.yml up -d --build>/dev/null

#stop-services:
#	@docker-compose -f docker-compose.dev.yml -f docker-compose.debug.yml down>/dev/null

query: ## Script called "query.sh"
	@echo "======================================================"
	@chmod +x ./Query/query.sh
	@$(SHELL) ./Query/query.sh $(STORAGE)/query_results


docker-run:
	@echo "======================================================"
	@echo "running $(MODULE_NAME)"
	@echo "======================================================"
	docker-compose up --build

flake8:
	@echo "======================================================"
	@echo flake8 $(PACKAGE)
	@echo "======================================================"
	flake8 --ignore=F401,E265,E129


.PHONY: clean-pyc clean-build clean-test clean

clean: clean-pyc clean-build clean-test clean-docs
	
clean-pyc: ## clean-pyc - remove Python file artifacts
	@echo "======================================================"
	@echo "clean-pyc - remove Python file artifacts in $(PACKAGE_NAME)"
	@echo "======================================================"
	rm -rf __pycache__ venv "*.pyc"
	find ./* -maxdepth 0 -name "*.pyc" -type f -delete
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-build: ## clean-build - remove build artifacts
	@echo "======================================================"
	@echo "clean-build - remove build artifacts in $(PACKAGE_NAME)"
	@echo "======================================================"
	rm -fr build/
	rm -fr dist/
	rm -fr **.egg-info/
	rm -fr .eggs/

clean-test: ## clean-test - remove test artifacts
	@echo "======================================================"
	@echo "clean-test - remove test artifacts in $(PACKAGE_NAME)"
	@echo "======================================================"
	rm -rf .tox/

clean-docs: ## clean-docs - remove documentation artifacts
	@echo "======================================================"
	@echo "clean-docs - remove documentation artifacts"
	@echo "======================================================"
	rm -rf docs/_build



list: ## Makefile target list
	@echo "======================================================"
	@echo Makefile target list
	@echo "======================================================"
	@cat Makefile | grep "^[a-z]" | awk '{print $$1}' | sed "s/://g" | sort