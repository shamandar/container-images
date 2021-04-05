DOCKER      ?= docker
REPO        ?= $(USER)
FROM_IMAGE  ?= alpine:3.13.4

OS_NAME     := $(firstword $(subst :, ,$(subst leap,opensuse,$(notdir $(FROM_IMAGE)))))
OS_VERSION  := $(lastword $(subst :, ,$(notdir $(FROM_IMAGE))))
DOCKERFILE  := docker/$(OS_NAME)/$(OS_VERSION)/Dockerfile
REQUIREMENTS:= docker/$(OS_NAME)/$(OS_VERSION)/Requirements
TAG_PREFIX  := $(REGISTRY)$(REPO)/$(OS_NAME)/$(OS_VERSION)

IMAGES := \
	alpine=3.13.4 \
	amazonlinux=2 \
	centos=7 \
	centos=8 \
	debian=10 \
	fedora=33 \
	opensuse/leap=15.2 \
	oraclelinux=8 \
	quay.io/centos/centos=stream

help usage:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: $(IMAGES) ## Build all Docker development images

list-images: ## List all Docker base images
	@for x in $(subst =,:,$(IMAGES)); do echo $$x; done

zeek-dev: ## Build Docker base image for zeek development
zeek: ## Build Docker runtime image for zeek deployment

zeek-dev:
	$(DOCKER) build . --network=host --build-arg FROM_IMAGE=$(FROM_IMAGE) --build-arg REQUIREMENTS=$(REQUIREMENTS).$@ --tag $(TAG_PREFIX)/$@ --file $(DOCKERFILE).$@

zeek: zeek-dev
	$(DOCKER) build . --network=host --build-arg FROM_IMAGE_DEV=$(TAG_PREFIX)/$< --build-arg FROM_IMAGE=$(FROM_IMAGE) --build-arg REQUIREMENTS=$(REQUIREMENTS).$@ --tag $(TAG_PREFIX)/$@ --file $(DOCKERFILE).$@

$(IMAGES):
	make zeek-dev FROM_IMAGE=$(subst =,:,$@)

clean: ## Prune Docker images
	$(DOCKER) image prune --force

sysclean: ## Prune Docker system
	$(DOCKER) system prune --force

.PHONY: help usage all list-images zeek-dev zeek $(IMAGES) clean sysclean
