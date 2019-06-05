SHELL = /bin/bash

# Include project environment configuration
-include .env

REGION ?= us-central1
PROJECT_ID ?= $(DEVSHELL_PROJECT_ID)
APP_ID ?= $(shell basename $(shell pwd))
CLOUD_SQL_INSTANCE ?= $(APP_ID)
CLOUD_SQL_TIER ?= db-f1-micro
IMAGE ?= gcr.io/$(PROJECT_ID)/$(APP_ID)
CLOUD_SQL_CONNECTION_NAME ?= $(PROJECT_ID):$(REGION):$(CLOUD_SQL_INSTANCE)

# Make it possible to pass arguments to Makefile from command line
# https://stackoverflow.com/a/6273809/1826109
ARGS = $(filter-out $@,$(MAKECMDGOALS))

.EXPORT_ALL_VARIABLES:

# Prints help based on annotations for Makefile commands
.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: sql-create
sql-create:  ## Create a Cloud SQL instance
	gcloud sql instances create $(CLOUD_SQL_INSTANCE) --tier=$(CLOUD_SQL_TIER) --region=$(REGION)

.PHONY: build
build:  ## Build container image
	gcloud builds submit --tag $(IMAGE)

.PHONY: deploy
deploy: ## Deploy container on Cloud Run
	gcloud beta run deploy $(APP_ID) --region $(REGION) --image $(IMAGE) --set-cloudsql-instances $(CLOUD_SQL_INSTANCE) --set-env-vars=CLOUD_SQL_CONNECTION_NAME=$(CLOUD_SQL_CONNECTION_NAME)

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
