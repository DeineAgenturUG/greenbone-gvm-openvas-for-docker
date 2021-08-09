PWD ?= $(PWD)
.DEFAULT_GOAL := all

all: build


.PHONY: build
build:
	cd ${PWD} ; \
	docker build \
		-t securecompliance/openvas \
		.

.PHONY: build-debug
build-debug:
	cd ${PWD} ; \
	docker build \
	--build-arg AUTOSSH_DEBUG=1 \
		-t securecompliance/openvas \
		.

.PHONY: run
run:
	cd ${PWD} ; \
	docker run --name openvas --rm \
	-e MASTER_ADDRESS=192.168.178.29 \
	-e MASTER_PORT=2222 \
	--volume "${PWD}/storage/openvas-plugins:/var/lib/openvas/plugins" \
	--volume "${PWD}/storage/gvm:/var/lib/gvm" \
	securecompliance/openvas 

.PHONY: run-exec
run-exec:
	cd ${PWD} ; \
	docker run -ti --name openvas --rm \
	-e MASTER_ADDRESS=192.168.178.29 \
	-e MASTER_PORT=2222 \
	--volume "${PWD}/storage/openvas-plugins:/var/lib/openvas/plugins" \
	--volume "${PWD}/storage/gvm:/var/lib/gvm" \
	securecompliance/openvas bash