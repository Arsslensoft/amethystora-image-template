# Your image, built on Amethystora. What you add goes in build_files/build.sh, and Fedora's packages, the
# apps, look and policy every machine starts with in packages, setup.json, branding/ and policy/ (the editor
# on amethystora.org writes those); this file seldom needs a change. Renovate moves the digest below onto each new
# Amethystora release.

FROM scratch AS ctx
COPY build_files /build_files
COPY cosign.pub /cosign.pub
COPY packages /packages
COPY setup.json /setup.json
COPY branding /branding
COPY policy /policy

FROM ghcr.io/iarsslen/amethystora:stable@sha256:b34ca0082a3c5fa93dd4f2c8b91781b0323527b5f8f46d753029b4c9cf0bdbf2

# Where the image is published. With it, the image takes its own updates only when they carry a
# signature cosign.pub checks; the build checks that, and that Amethystora's own checks still stand.
ARG IMAGE_REPOSITORY=""

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/build_files/build.sh && \
    bash /ctx/build_files/files.sh && \
    if [ -n "${IMAGE_REPOSITORY}" ]; then \
        /usr/libexec/amethystora-trust-image "${IMAGE_REPOSITORY}" /ctx/cosign.pub; \
    fi && \
    /usr/libexec/amethystora-image-check ${IMAGE_REPOSITORY}

RUN bootc container lint
