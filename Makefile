DOCKER      ?= docker
REPO        ?= $(USER)
FROM_IMAGE  ?= alpine:3.13.4

OS_NAME     := $(subst leap,opensuse,$(firstword $(subst :, ,$(notdir $(FROM_IMAGE)))))
OS_VERSION  := $(lastword $(subst :, ,$(notdir $(FROM_IMAGE))))
DOCKERFILE  := docker/$(OS_NAME)/$(OS_VERSION)/Dockerfile
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

zeek-dev: ## Build Docker base image for zeek development
zeek: ## Build Docker runtime image for zeek deployment
zeek-dev zeek:
	$(DOCKER) build . --network=host --build-arg FROM_IMAGE=$(FROM_IMAGE) --tag $(TAG_PREFIX)/$@ --file $(DOCKERFILE).$@

all: $(IMAGES) ## Build all Docker images

$(IMAGES):
	make zeek-dev FROM_IMAGE=$(subst =,:,$@)
	make zeek FROM_IMAGE=$(subst =,:,$@)

clean: ## Prune Docker images
	$(DOCKER) image prune --force

sysclean: ## Prune Docker system
	$(DOCKER) system prune --force

.PHONY: help usage zeek-dev zeek all $(IMAGES) clean sysclean
