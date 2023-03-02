VERSION=0.1.1
DOCKER_IMAGE=etriasnl/cups
DOCKER_PROGRESS?=auto
MAKEFLAGS += --warn-undefined-variables --always-make
.DEFAULT_GOAL := _

TAG=${DOCKER_IMAGE}:${VERSION}
LATEST_TAG=${DOCKER_IMAGE}:latest

lint:
	docker run -it --rm -v "$(shell pwd):/app" -w /app hadolint/hadolint hadolint --ignore DL3059 "Dockerfile"
release: lint
	docker buildx build --progress "${DOCKER_PROGRESS}" -t "${TAG}" -t "${LATEST_TAG}" --load .
publish: release
	docker push "${TAG}"
	docker push "${LATEST_TAG}"
