# Your image, built on Amethystora. What you add goes in build_files/build.sh; this file seldom needs a
# change. Renovate moves the digest below onto each new Amethystora release.

FROM scratch AS ctx
COPY build_files /build_files
COPY cosign.pub /cosign.pub

FROM ghcr.io/iarsslen/amethystora:stable@sha256:6a120c703b2a0d9998d7bef867aace02b5884e1d4aeb5d1ae7e00cd1a5bd2e7c

# Where the image is published. With it, the image takes its own updates only when they carry a
# signature cosign.pub checks; the build checks that, and that Amethystora's own checks still stand.
ARG IMAGE_REPOSITORY=""

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/build_files/build.sh && \
    if [ -n "${IMAGE_REPOSITORY}" ]; then \
        /usr/libexec/amethystora-trust-image "${IMAGE_REPOSITORY}" /ctx/cosign.pub; \
    fi && \
    /usr/libexec/amethystora-image-check ${IMAGE_REPOSITORY}

RUN bootc container lint
