PROJECTPATH = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

VENV := .venv
VENV_PIP := $(PROJECTPATH)/$(VENV)/bin/pip
VENV_PYTHON := $(PROJECTPATH)/$(VENV)/bin/python3


PROJECT := deploy_instant-search
BASE_IMAGE ?= node
IMAGE_TAG ?= latest
PROJECT_VERSION ?= latest

build:
	docker build \
		--build-arg="BASE_IMAGE=$(BASE_IMAGE)" \
		--build-arg="IMAGE_TAG=$(IMAGE_TAG)" \
		--tag $(PROJECT):$(PROJECT_VERSION) \
		$(PROJECTPATH)

run-dev: build
	docker run --rm -p 3000:3000 $(PROJECT):$(PROJECT_VERSION)

.PHONY: build run-dev
