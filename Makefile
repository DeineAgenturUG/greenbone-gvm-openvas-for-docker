
BUILD_ID ?= ${USER}
CHECKSUM ?= ${CHECKSUM:-0}


.PHONY: builder
builder:
	docker build -t apk_builder:${BUILD_ID} builder/

target:
	mkdir -p target
	rm -rf target/*.tar.gz target/*.apk
	mkdir -p aports2

.PHONY: cp_build_files
cp_build_files:
	cp -r aports/community/gvm-libs aports2/community/
	cp -r aports/community/openvas-smb aports2/community/
	cp -r aports/community/gvmd aports2/community/
	cp -r aports/community/openvas aports2/community/
	cp -r aports/community/py3-gvm aports2/community/
	cp -r aports/community/gvm-tools aports2/community/
	cp -r aports/community/ospd-openvas aports2/community/
	cp -r aports/community/greenbone-security-assistant aports2/community/

aports:
	git clone git://git.alpinelinux.org/aports

.PHONY: aports_update
aports_update: aports
	GIT_DIR=aports/.git git fetch origin -p
	GIT_DIR=aports/.git git pull origin master

.PHONY: aports_set_V3.14
aports_set_V3.14: aports
	GIT_DIR=aports/.git git fetch origin -p
	GIT_DIR=aports/.git git checkout origin/3.14-stable

.PHONY: aports_update_V3.14
aports_update_V3.14: aports_set_V3.14
	GIT_DIR=aports/.git git fetch origin -p
	GIT_DIR=aports/.git git pull origin 3.14-stable

user.abuild:
	mkdir -p user.abuild

build: builder target
	docker run \
		-v ${PWD}/user.abuild/:/home/packager/.abuild \
		-v ${PWD}/aports2:/work \
		-v ${PWD}/target:/target \
		-v ${HOME}/.gitconfig/:/home/packager/.gitconfig \
		-e CHECKSUM=${CHECKSUM} \
		apk_builder:${BUILD_ID} \
		sh -c '~/bin/build.sh'

build2: builder target
	docker run -ti \
		-v ${PWD}/user.abuild/:/home/packager/.abuild \
		-v ${PWD}/aports2:/work \
		-v ${PWD}/target:/target \
		-v ${HOME}/.gitconfig/:/home/packager/.gitconfig \
		-e CHECKSUM=${CHECKSUM} \
		apk_builder:${BUILD_ID} \
		sh 
