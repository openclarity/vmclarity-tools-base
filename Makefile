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
	$(info "Building docker image...")
	# build both images
	docker buildx build --platform=linux/amd64,linux/arm64 -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	# load just the current platform
	# https://github.com/docker/buildx/issues/59#issuecomment-1168619521
	docker buildx build --load --platform linux/$(shell uname -m) -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

.PHONY: push-docker
push-docker: docker ## Build and Push Docker image
	$(info "Publishing docker image...")
	# push both platforms as one image manifest list
	docker buildx build --push --platform linux/arm64,linux/amd64 -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
