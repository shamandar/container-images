DOCKER      ?= docker
REPO        ?= $(REGISTRY)$(USER)
FROM_IMAGE  ?= alpine:3.13.4@sha256:ec14c7992a97fc11425907e908340c6c3d6ff602f5f13d899e6b7027c9b4133a
TAG_VERSION ?= latest     ## TODO: Override this with proper release version

OS_NAME     := $(firstword $(subst :, ,$(subst leap,opensuse,$(notdir $(FROM_IMAGE)))))
OS_VERSION  := $(lastword $(subst :, ,$(firstword $(subst @, ,$(notdir $(FROM_IMAGE))))))
DOCKERFILE  := docker/$(OS_NAME)/$(OS_VERSION)/Dockerfile
REQUIREMENTS:= docker/$(OS_NAME)/$(OS_VERSION)/Requirements
TAG_PREFIX  := $(REPO)/$(OS_NAME)/$(OS_VERSION)

ifdef CI
	DOCKER_BUILD := $(DOCKER) build .
else
	DOCKER_BUILD := $(DOCKER) build . --network=host --cpuset-cpus=0
endif

# Docker tag version separator `:` is conflicting with Makefile `:`.
# Temporary use `-` as Docker tag separator in Makefile targets.
_TARGET_DEFAULT_DOCKER_IMAGES := \
	alpine-3.13.4 \
	amazonlinux-2 \
	centos-7 \
	centos-8 \
	debian-10 \
	fedora-33 \
	opensuse/leap-15.2 \
	oraclelinux-8 \
	quay.io/centos/centos-stream \
	ubuntu-18.04 \
	ubuntu-20.04

_NORM   := \033[0m
_BLACK  := \033[31m
_RED    := \033[31m
_GREEN  := \033[32m
_YELLOW := \033[33m
_BLUE   := \033[34m
_MAGENTA:= \033[35m
_CYAN   := \033[36m
_WHITE  := \033[37m

help usage:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##"}; {printf "$(_CYAN)%-20s$(_NORM) %s\n", $$1, $$2}'

all: $(_TARGET_DEFAULT_DOCKER_IMAGES) ## Build all Zeek development images

list-images: ## List all default Docker images
	@for x in $(subst -,:,$(_TARGET_DEFAULT_DOCKER_IMAGES)); do printf "$(_CYAN)%s$(_NORM)\n" $$x; done

zeek-dev:       ## Docker base image for Zeek development
zeek-runtime:   ## Docker base image for Zeek runtime
zeek-build:     ## Intermediate Docker image for compiling Zeek
zeek:           ## Docker App image for running Zeek

zeek-dev zeek-runtime:
	$(DOCKER_BUILD) --build-arg FROM_IMAGE_BASE=$(FROM_IMAGE) --build-arg REQUIREMENTS=$(REQUIREMENTS).$@ --tag $(TAG_PREFIX)/$@:$(TAG_VERSION) --file $(DOCKERFILE).$@

zeek-build: zeek-dev
	$(DOCKER_BUILD) --build-arg FROM_IMAGE_BASE=$(TAG_PREFIX)/$<:$(TAG_VERSION) --tag $(TAG_PREFIX)/$@:$(TAG_VERSION) --file $(DOCKERFILE).$@

zeek: zeek-build zeek-runtime
	$(DOCKER_BUILD) --build-arg FROM_IMAGE_ARTIFACT=$(TAG_PREFIX)/$(firstword $^):$(TAG_VERSION) --build-arg FROM_IMAGE_BASE=$(TAG_PREFIX)/$(lastword $^):$(TAG_VERSION) --tag $(TAG_PREFIX)/$@:$(TAG_VERSION) --file $(DOCKERFILE).$@

$(_TARGET_DEFAULT_DOCKER_IMAGES):
	make zeek-dev FROM_IMAGE=$(subst -,:,$@)

clean: ## Prune Docker images
	$(DOCKER) image prune --force

sysclean: ## Prune Docker system
	$(DOCKER) system prune --force

.PHONY: help usage all list-images zeek-dev zeek-runtime zeek-build zeek $(_TARGET_DEFAULT_DOCKER_IMAGES) clean sysclean
