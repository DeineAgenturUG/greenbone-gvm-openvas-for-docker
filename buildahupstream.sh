#!/usr/bin/env bash
# build_buildah_upstream.sh
#
ctr=$(buildah from fedora)
buildah config --env GOPATH=/root/buildah $ctr
buildah run $ctr /bin/sh -c 'dnf -y install --enablerepo=updates-testing \
     make \
     golang \
     bats \
     btrfs-progs-devel \
     device-mapper-devel \
     glib2-devel \
     gpgme-devel \
     libassuan-devel \
     libseccomp-devel \
     git \
     bzip2 \
     go-md2man \
     runc \
     fuse-overlayfs \
     fuse3 \
     containers-common; \
     mkdir -p /root/buildah; \
     git clone https://github.com/containers/buildah /root/buildah/src/github.com/containers/buildah; \
     cd /root/buildah/src/github.com/containers/buildah; \
     make; \
     make install; \
     rm -rf /root/buildah/*; \
     dnf -y remove bats git golang go-md2man make; \
     dnf clean all'

buildah run $ctr -- sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' /etc/containers/storage.conf

buildah run $ctr /bin/sh -c 'mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock'

buildah config --env _BUILDAH_STARTED_IN_USERNS="" --env BUILDAH_ISOLATION=chroot $ctr
buildah commit $ctr buildahupstream
