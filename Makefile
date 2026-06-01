VERSION    ?= latest
GHCR_NS    ?= ghcr.io/helphyy
IMAGE      := claudock:$(VERSION)
REMOTE     := $(GHCR_NS)/claudock

# Cache-bust forces the Claude Code layer to re-fetch the current version
# on every `make build`.
CACHEBUST  := $(shell date +%s)

.PHONY: build push tag run shell version clean help

help:
	@echo "Targets:"
	@echo "  build      Build the claudock image (tags: claudock:$(VERSION))"
	@echo "  tag        Tag the local image for GHCR (latest + $(VERSION))"
	@echo "  push       tag + docker push to $(REMOTE)"
	@echo "  run        Throwaway interactive container"
	@echo "  shell      Bash shell in a throwaway container"
	@echo "  version    Print Claude Code version from the built image"
	@echo "  clean      Remove the local image tag"

build:
	docker build -t $(IMAGE) -f Dockerfile --build-arg CACHEBUST=$(CACHEBUST) .

tag: build
	docker tag $(IMAGE) $(REMOTE):latest
	docker tag $(IMAGE) $(REMOTE):$(VERSION)

push: tag
	docker push $(REMOTE):latest
	docker push $(REMOTE):$(VERSION)

run: build
	docker run --rm -it $(IMAGE)

shell: build
	docker run --rm -it --entrypoint /bin/bash $(IMAGE)

version: build
	docker run --rm $(IMAGE) claude --version

clean:
	-docker rmi $(IMAGE)
