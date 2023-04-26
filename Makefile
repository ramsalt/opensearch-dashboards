-include env_make

DASHBOARDS_VER ?= 2.6.0
DASHBOARDS_VER_MINOR=$(shell echo "${DASHBOARDS_VER}" | grep -oE '^[0-9]+\.[0-9]+')

NODEJS_VER ?= $(shell wget -qO- "https://raw.githubusercontent.com/opensearch-project/opensearch-dashboards/$(DASHBOARDS_VER)/.node-version")

TAG ?= $(DASHBOARDS_VER_MINOR)

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

ifneq ($(BASE_IMAGE_STABILITY_TAG),)
    BASE_IMAGE_TAG := $(BASE_IMAGE_TAG)-$(BASE_IMAGE_STABILITY_TAG)
endif

REPO = ghcr.io/ramsalt/opensearch-dashboards
NAME = opensearch-dashboards-$(DASHBOARDS_VER)

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg NODEJS_VER=$(NODEJS_VER) \
		--build-arg DASHBOARDS_VER=$(DASHBOARDS_VER) \
		./

test:
	cd ./tests && IMAGE=$(REPO):$(TAG) NAME=$(NAME) OS_VER=$(DASHBOARDS_VER_MINOR) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) -e DEBUG=1 $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
