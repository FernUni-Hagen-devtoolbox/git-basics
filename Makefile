IMAGE_NAME := git-basics-dev
CONTAINER_NAME := git-basics-dev
PORT := 8888
NOTEBOOK_DIR := /home/jovyan
CONTENT_DIR := $(CURDIR)/lesson-content
CONTENT_COPY_DIR := $(CURDIR)/lesson-content-runtime
JUPYTER_DIR := $(CURDIR)/.jupyter

.PHONY: help build run stop shell clean prepare-content-copy

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make build  - build the local Jupyter image' \
		'  make run    - start JupyterLab with a copied lesson-content tree' \
		'  make init-content - reset lesson-content to a clean starter state' \
		'  make stop   - stop the local dev container' \
		'  make shell  - open a shell inside the image' \
		'  make clean  - remove the local image'

build:
	docker build -t $(IMAGE_NAME) .

prepare-content-copy:
	rm -rf $(CONTENT_COPY_DIR)
	cp -a $(CONTENT_DIR) $(CONTENT_COPY_DIR)

run: prepare-content-copy
	docker run -d --rm \
		--name $(CONTAINER_NAME) \
		-p $(PORT):8888 \
		-v $(CONTENT_COPY_DIR):/home/jovyan \
		-v $(JUPYTER_DIR):/home/jovyan/.jupyter \
		-w /home/jovyan \
		$(IMAGE_NAME) \
		start-notebook.sh --ServerApp.token='' --ServerApp.password='' --ServerApp.allow_origin='*' --ServerApp.root_dir=$(NOTEBOOK_DIR)
	@printf '%s\n' 'JupyterLab is running at http://127.0.0.1:$(PORT)/lab'

stop:
	-docker stop $(CONTAINER_NAME)
	rm -rf $(CONTENT_COPY_DIR)

shell: prepare-content-copy
	docker run --rm -it \
		-v $(CONTENT_COPY_DIR):/home/jovyan \
		-v $(JUPYTER_DIR):/home/jovyan/.jupyter \
		-w /home/jovyan \
		$(IMAGE_NAME) \
	bash

clean:
	docker image rm $(IMAGE_NAME)