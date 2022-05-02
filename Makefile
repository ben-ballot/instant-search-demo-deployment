PROJECTPATH = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

VENV := .venv
VENV_PIP := $(PROJECTPATH)/$(VENV)/bin/pip
VENV_PYTHON := $(PROJECTPATH)/$(VENV)/bin/python3


IMAGE := instant-search-demo
BASE_IMAGE ?= node
BASE_TAG ?= 9.11
APP_REVISION ?= $(shell cd $(PROJECTPATH) && git rev-parse @:./instant-search-demo)
APP_VERSION ?= $(shell cd $(PROJECTPATH) && git describe --tags $$(git rev-list --tags --max-count=1))

DATE ?= $(shell date "+%F-%H%M%S")

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
		--build-opt="build-arg=BASE_IMAGE=$(BASE_IMAGE)" \
		--build-opt="build-arg=DATE=$(DATE)" \
		--build-opt="build-arg=IMAGE_TAG=$(BASE_TAG)" \
		--build-opt="build-arg=REVISION=$(APP_REVISION)" \
		--build-opt="build-arg=VERSION=$(APP_VERSION)" \
		--tag $(IMAGE):$(APP_VERSION) \
		--file Dockerfile \
		$(PROJECTPATH)

build-dev: DATE=dev
build-dev: APP_REVISION=dev
build-dev: APP_VERSION=dev
build-dev: build

build-minikube-dev: DATE=dev
build-minikube-dev: APP_REVISION=dev
build-minikube-dev: APP_VERSION=dev
build-minikube-dev: build-minikube

push: build
	docker push $(IMAGE):$(APP_VERSION)

run-dev: build-dev
	docker run --rm -p 3000:3000 $(IMAGE):$(IMAGE_TAG)
	@echo "Connect on http://localhost:3000"

run-minikube-dev: build-minikube-dev
	minikube kubectl -- apply -k  $(PROJECTPATH)/k8s/base
	@echo "Connect on http://$(shell minikube ip):30000"

clean-dev:
	minikube kubectl -- delete deployment $(IMAGE)-deployment


update:
	@git submodule update --init --recursive

.PHONY: build build-dev build-minikube build-minikube-dev push run-dev run-minikube-dev
.PHONY: update
