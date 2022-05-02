PROJECTPATH = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

APP ?= instant-search-demo
IMAGE ?= instant-search-demo
BASE_IMAGE ?= node
BASE_TAG ?= 9.11
APP_REVISION ?= $(shell cd $(PROJECTPATH) && git rev-parse @:./instant-search-demo)
APP_VERSION ?= $(shell cd $(PROJECTPATH) && git describe --tags $$(git rev-list --tags --max-count=1))

TARGET_ENV := dev staging prod
TARGET_BUILD = $(addprefix build-, $(TARGET_ENV))
TARGET_BUILD_MINIKUBE = $(addprefix build-minikube-, $(TARGET_ENV))
TARGET_DEPLOY = $(addprefix deploy-, $(TARGET_ENV))
TARGET_DEPLOY_MINIKUBE = $(addprefix deploy-minikube-, $(TARGET_ENV))
TARGET_CLEAN = $(addprefix clean-, $(TARGET_ENV))
TARGET_CLEAN_MINIKUBE = $(addprefix clean-minikube-, $(TARGET_ENV))

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

$(TARGET_BUILD): build-%: build

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

$(TARGET_BUILD_MINIKUBE): build-minikube-%: build-minikube

push:
	docker push $(IMAGE):$(APP_VERSION)

$(TARGET_DEPLOY): deploy-%: build-% push
	kubectl apply -k  $(PROJECTPATH)/k8s/overlays/$*
	@echo "$(IMAGE) Deployed as a nodePort service on port 30000"

$(TARGET_DEPLOY_MINIKUBE): deploy-minikube-%: build-minikube-%
	minikube kubectl -- apply -k  $(PROJECTPATH)/k8s/overlays/$*
	@echo "Connect on http://$(shell minikube ip):30000"

$(TARGET_CLEAN): clean-%:
	kubectl delete deployment $(APP)-deployment
	kubectl delete svc $(APP)

$(TARGET_CLEAN_MINIKUBE): clean-minikube-%:
	minikube kubectl -- delete deployment $(APP)-deployment
	minikube kubectl -- delete svc $(APP)

update-git:
	@git submodule update --init --recursive

update: update-git build


.PHONY: $(TARGET_CLEAN_MINIKUBE) $(TARGET_BUILD) $(TARGET_DEPLOY) $(TARGET_BUILD_MINIKUBE) $(TARGET_DEPLOY_MINIKUBE)
.PHONY: build deploy push update
