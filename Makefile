.PHONY: build echo 
SHELL := /bin/bash 
REPO ?= hamropatrorepo/vector
VERSION ?= `date +1%F`
IMAGE = ${REPO}:${VERSION}

build:
	IMAGE=${IMAGE} bash vector-container/build.sh

run-dev:
	docker run -it -v `pwd`/vector-container/supervisord.conf:/etc/supervisor/conf.d/supervisord.conf -v `pwd`/vector-container/http.cfg:/root/proxy/http.cfg -v `pwd`/vector-container/vector-config.json:/root/vector-config.json -p 8000:8000 -p 8080:80 ${IMAGE}

run:
	docker run -p 8000:8000 -p 8001:8001 -p 8080:80 ${IMAGE}