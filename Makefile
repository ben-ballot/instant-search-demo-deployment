PROJECTPATH = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

VENV := .venv
VENV_PIP := $(PROJECTPATH)/$(VENV)/bin/pip
VENV_PYTHON := $(PROJECTPATH)/$(VENV)/bin/python3


IMAGE := instant-search-demo
BASE_IMAGE ?= node
BASE_TAG ?= latest
IMAGE_TAG ?= $(shell cd $(PROJECTPATH) && git rev-parse @:./instant-search-demo)
DATE ?= $(shell date "+%F-%H%M%s")

build:
	docker build \
		--build-arg="BASE_IMAGE=$(BASE_IMAGE)" \
		--build-arg="DATE=$(DATE)" \
		--build-arg="IMAGE_TAG=$(BASE_TAG)" \
		--tag $(IMAGE):$(IMAGE_TAG) \
		$(PROJECTPATH)

build-dev: DATE = "dev"
build-dev: IMAGE_TAG = "dev"
build-dev: build

run-dev: build-dev
	docker run --rm -p 3000:3000 $(IMAGE):$(IMAGE_TAG)

.PHONY: build run-dev
