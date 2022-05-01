PROJECTPATH = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

VENV := .venv
VENV_PIP := $(PROJECTPATH)/$(VENV)/bin/pip
VENV_PYTHON := $(PROJECTPATH)/$(VENV)/bin/python3


IMAGE := instant-search-demo
BASE_IMAGE ?= node
BASE_TAG ?= 9.11
REVISION := $(shell cd $(PROJECTPATH) && git rev-parse @:./instant-search-demo)
APP_REVISION ?= $(REVISION)
APP_VERSION ?= $(REVISION)

$(info $$REVISION  = $(REVISION)) 
$(info $$APP_REVISION  = $(APP_REVISION)) 
$(info $$APP_VERSION  = $(APP_VERSION)) 

DATE ?= $(shell date "+%F-%H%M%s")

build:
	docker build \
		--build-arg="BASE_IMAGE=$(BASE_IMAGE)" \
		--build-arg="DATE=$(DATE)" \
		--build-arg="IMAGE_TAG=$(BASE_TAG)" \
		--build-arg="REVISION=$(APP_REVISION)" \
		--build-arg="VERSION=$(APP_VERSION)" \
		--tag $(IMAGE):$(APP_VERSION) \
		--file Dockerfile \
		$(PROJECTPATH)

build-minikube:
	minikube image build \
		--build-opt="build-arg=\"BASE_IMAGE=$(BASE_IMAGE)\"" \
		--build-opt="build-arg=\"DATE=$(DATE)\"" \
		--build-opt="build-arg=\"IMAGE_TAG=$(BASE_TAG)\"" \
		--build-opt="build-arg=\"REVISION=$(APP_REVISION)\"" \
		--build-opt="build-arg=\"VERSION=$(APP_VERSION)\"" \
		--tag $(IMAGE):$(APP_VERSION) \
		--file Dockerfile \
		$(PROJECTPATH)

build-dev: DATE = "dev"
build-dev: IMAGE_TAG = "dev"
build-dev: build

push: build
	docker push $(IMAGE):$(APP_VERSION)

run-dev: build-dev"instant-search-demo"

	docker run --rm -p 3000:3000 $(IMAGE):$(IMAGE_TAG)

.PHONY: build build-dev run-dev
