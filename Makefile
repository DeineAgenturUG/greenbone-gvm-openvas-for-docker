PWD ?= $(PWD)
.DEFAULT_GOAL := all

all: apkbuild build

.PHONY: apkbuild
apkbuild:
	cd ${PWD}/apk-build ; \
	make build


.PHONY: build
build: apkbuild
	cd ${PWD} ; \
	docker build --no-cache  \
		-t securecompliance/openvas \
		.