VERSION    ?= latest
GHCR_NS    ?= ghcr.io/helphyy

MINIMAL_IMAGE  := claudock-minimal:$(VERSION)
DEV_IMAGE      := claudock-dev:$(VERSION)
CLOUD_IMAGE    := claudock-cloud:$(VERSION)
SECURITY_IMAGE := claudock-security:$(VERSION)
DATA_IMAGE     := claudock-data:$(VERSION)
DOC_IMAGE      := claudock-doc:$(VERSION)
FULL_IMAGE     := claudock-full:$(VERSION)

# Order matters for build-all: minimal first, then everything that extends it,
# then full (which extends dev).
VARIANTS := minimal dev cloud security data doc full

.PHONY: build-minimal build-dev build-cloud build-security build-data build-doc build-full build-all \
        push-minimal push-dev push-cloud push-security push-data push-doc push-full push-all \
        tag-minimal tag-dev tag-cloud tag-security tag-data tag-doc tag-full \
        run shell version clean clean-all help

help:
	@echo "Image variants:"
	@echo "  build-minimal     Claude + zsh + code-server + Firefox + Chromium + git + minimal tools"
	@echo "  build-dev         minimal + Python/Node/Go/Rust + dev tools"
	@echo "  build-cloud       minimal + HashiCorp + k8s + AWS/GCP/Azure + Ansible"
	@echo "  build-security    minimal + audit/pentest tools"
	@echo "  build-data        minimal + JupyterLab + pandas/polars/duckdb + SQL clients"
	@echo "  build-doc         minimal + LaTeX + pandoc + Hugo + mdBook + asciidoctor"
	@echo "  build-full        dev + cloud + security combined"
	@echo "  build-all         Build all seven"
	@echo ""
	@echo "Push to GHCR (requires docker login ghcr.io):"
	@echo "  push-<variant>    where <variant> is minimal/dev/cloud/security/data/doc/full"
	@echo "  push-all          Push every variant"
	@echo ""
	@echo "Misc:"
	@echo "  run               Throwaway interactive container (dev)"
	@echo "  shell             Bash shell in a throwaway dev container"
	@echo "  version           Print Claude Code version from minimal image"
	@echo "  clean             Remove local image tags"

build-minimal:
	docker build -t $(MINIMAL_IMAGE) -f Dockerfile.minimal .

build-dev: build-minimal
	docker build -t $(DEV_IMAGE) -f Dockerfile.dev --build-arg BASE_IMAGE=$(MINIMAL_IMAGE) .

build-cloud: build-minimal
	docker build -t $(CLOUD_IMAGE) -f Dockerfile.cloud --build-arg BASE_IMAGE=$(MINIMAL_IMAGE) .

build-security: build-minimal
	docker build -t $(SECURITY_IMAGE) -f Dockerfile.security --build-arg BASE_IMAGE=$(MINIMAL_IMAGE) .

build-data: build-minimal
	docker build -t $(DATA_IMAGE) -f Dockerfile.data --build-arg BASE_IMAGE=$(MINIMAL_IMAGE) .

build-doc: build-minimal
	docker build -t $(DOC_IMAGE) -f Dockerfile.doc --build-arg BASE_IMAGE=$(MINIMAL_IMAGE) .

# claudock-full = dev + cloud + security, chained.
# Pass 1: apply Dockerfile.cloud onto dev   -> tag claudock-full:VERSION
# Pass 2: apply Dockerfile.security onto it -> overwrite same tag
# No intermediate tag pollutes the registry; cloud/security stay single-source.
build-full: build-dev
	docker build -t $(FULL_IMAGE) -f Dockerfile.cloud --build-arg BASE_IMAGE=$(DEV_IMAGE) .
	docker build -t $(FULL_IMAGE) -f Dockerfile.security --build-arg BASE_IMAGE=$(FULL_IMAGE) .

build-all: build-minimal build-dev build-cloud build-security build-data build-doc build-full

run: build-dev
	docker run --rm -it $(DEV_IMAGE)

shell: build-dev
	docker run --rm -it --entrypoint /bin/bash $(DEV_IMAGE)

version: build-minimal
	docker run --rm $(MINIMAL_IMAGE) claude --version

# --- tag for GHCR ---
define TAG_TEMPLATE
tag-$(1):
	docker tag claudock-$(1):$$(VERSION) $$(GHCR_NS)/claudock-$(1):latest
	docker tag claudock-$(1):$$(VERSION) $$(GHCR_NS)/claudock-$(1):$$(VERSION)
endef

$(foreach v,$(VARIANTS),$(eval $(call TAG_TEMPLATE,$(v))))

# --- push ---
define PUSH_TEMPLATE
push-$(1): tag-$(1)
	docker push $$(GHCR_NS)/claudock-$(1):latest
	docker push $$(GHCR_NS)/claudock-$(1):$$(VERSION)
endef

$(foreach v,$(VARIANTS),$(eval $(call PUSH_TEMPLATE,$(v))))

push-all: push-minimal push-dev push-cloud push-security push-data push-doc push-full

clean:
	-docker rmi $(MINIMAL_IMAGE) $(DEV_IMAGE) $(CLOUD_IMAGE) $(SECURITY_IMAGE) $(DATA_IMAGE) $(DOC_IMAGE) $(FULL_IMAGE)
