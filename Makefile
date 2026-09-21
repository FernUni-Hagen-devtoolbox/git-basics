IMAGE_NAME := git-basics-dev
CONTAINER_NAME := git-basics-dev
PORT := 8888
NOTEBOOK_DIR := /home/jovyan
WORKSPACE := uebung-01

.PHONY: help build run stop shell clean

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make build                    - build the Binder-compatible image' \
		'  make run                      - start JupyterLab with workspace uebung-01' \
		'  make run WORKSPACE=uebung-03  - start another prepared workspace' \
		'  make stop                     - stop the local container' \
		'  make shell                    - open a shell inside the image' \
		'  make clean                    - remove the local image'

build:
	docker build -f .binder/Dockerfile -t $(IMAGE_NAME) .

run:
	docker run -d --rm \
		--name $(CONTAINER_NAME) \
		-p $(PORT):8888 \
		$(IMAGE_NAME) \
		start-notebook.py \
		--IdentityProvider.token='' \
		--ServerApp.password='' \
		--ServerApp.allow_origin='*' \
		--ServerApp.root_dir=$(NOTEBOOK_DIR) \
		--ServerApp.default_url=/lab/workspaces/$(WORKSPACE)
	@printf '%s\n' 'JupyterLab is running at http://127.0.0.1:$(PORT)/lab/workspaces/$(WORKSPACE)'

stop:
	-docker stop $(CONTAINER_NAME)

shell:
	docker run --rm -it \
		$(IMAGE_NAME) \
		bash

clean:
	docker image rm $(IMAGE_NAME)
