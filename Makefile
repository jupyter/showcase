# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

.PHONY: help build dev

IMAGE:=jupyter-incubator/showcase

help:
	@cat Makefile

build:
	@docker build --rm -t $(IMAGE) .

dev:
	@docker run --rm -it \
		-p 8888:8888 \
		$(IMAGE) \
		/home/main/start-notebook.sh --ip=0.0.0.0
