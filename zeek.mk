zeek-dev:       ## Docker base image for Zeek development
zeek-runtime:   ## Docker base image for Zeek runtime
zeek-build:     ## Intermediate Docker image for compiling Zeek
zeek:           ## Docker App image for running Zeek

zeek-dev zeek-runtime:
	$(DOCKER_BUILD) \
		--build-arg FROM_IMAGE_BASE=$(FROM_IMAGE) \
		--build-arg REQUIREMENTS=$(REQUIREMENTS).$@ \
		--tag $(TAG_PREFIX)/$@:$(TAG_VERSION) \
		--file $(DOCKERFILE).$@

zeek-build: zeek-dev
	$(DOCKER_BUILD) \
		--build-arg FROM_IMAGE_BASE=$(TAG_PREFIX)/$<:$(TAG_VERSION) \
		--tag $(TAG_PREFIX)/$@:$(TAG_VERSION) \
		--file $(DOCKERFILE).$@

zeek: zeek-build zeek-runtime
	$(DOCKER_BUILD) \
		--build-arg FROM_IMAGE_ARTIFACT=$(TAG_PREFIX)/$(firstword $^):$(TAG_VERSION) \
		--build-arg FROM_IMAGE_BASE=$(TAG_PREFIX)/$(lastword $^):$(TAG_VERSION) \
		--tag $(TAG_PREFIX)/$@:$(TAG_VERSION) \
		--file $(DOCKERFILE).$@

.PHONY: zeek-dev zeek-runtime zeek-build zeek
