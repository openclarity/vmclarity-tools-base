SHELL=/bin/bash

# Project variables
DOCKER_IMAGE ?= ghcr.io/openclarity/vmclarity-tools-base
DOCKER_TAG ?= $(shell git rev-parse HEAD)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: docker
docker: ## Build Docker image
	@(echo "Building docker image...")
	docker buildx build --load -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

.PHONY: push-docker
push-docker: docker ## Build and Push Docker image
	@(echo "Publishing docker image...")
	docker buildx build --push --platform linux/arm64,linux/amd64 -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
