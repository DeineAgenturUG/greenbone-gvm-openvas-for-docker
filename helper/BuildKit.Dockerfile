# To work around the problem about the already used PORTS in parallel builds, it needs a CNI in the buildx driver
# SEE: https://github.com/docker/buildx/issues/678
# > docker run --privileged --rm tonistiigi/binfmt --install all
# > docker buildx create --use
# > docker build -f BuildKit.Dockerfile -t deineagenturug/buildkit:latest .
# > docker buildx create --name "GVM_CNI_BUILDER" --driver-opt image=deineagenturug/buildkit:latest --buildkitd-flags '--oci-worker-net=cni --oci-worker-gc-keepstorage 200000' --use
# > docker buildx create --name "GVM_CNI_BUILDER" --append --node <name-for-the-node> <ssh://user@host>
# > docker buildx create --name "GVM_CNI_BUILDER2" --leave --node <name-for-the-node>
#
# on remote systems you should run:
#
# > sudo groupadd docker
# > sudo usermod -aG docker $USER
# > newgrp docker
# > sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
# > sudo chmod g+rwx "$HOME/.docker" -R
# > sudo apt install net-tools
# > docker run --privileged --rm tonistiigi/binfmt --install all
# > docker buildx create --use
# > docker buildx build --platform "linux/arm64,linux/arm/v7" -f buildkit.Dockerfile -t deineagenturug/buildkit:latest .
ARG BUILDKIT_TAG=latest
ARG CNI_VERSION=v1.1.1
FROM moby/buildkit:${BUILDKIT_TAG} AS buildkit_upstream_tag

FROM buildkit_upstream_tag
ARG CNI_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG BUILDKIT_TAG
ENV BUILDKIT_TAG="${BUILDKIT_TAG}"
ENV CNI_VERSION="${CNI_VERSION}"

RUN echo "BUILDKIT_TAG=[${BUILDKIT_TAG}], CNI_VERSION=[${CNI_VERSION}]"
RUN apk add --no-cache curl iptables

WORKDIR /opt/cni/bin
RUN curl -Ls https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-${TARGETOS}-${TARGETARCH}-${CNI_VERSION}.tgz | tar xzv
ADD https://raw.githubusercontent.com/moby/buildkit/master/hack/fixtures/cni.json /etc/buildkit/cni.json
RUN ls -al /etc/buildkit && buildkitd --version
