# Build and look at your image on your own machine. The workflow in .github/workflows/build.yml runs the
# same recipes.

image_name := lowercase(env("IMAGE_NAME", file_name(justfile_directory())))
tag := env("DEFAULT_TAG", "stable")

# Where the image is published, such as ghcr.io/you/your-image; empty for a build that stays local
repository := env("IMAGE_REPOSITORY", "")

[private]
default:
    @just --list

# Build the image, as localhost/<name>:stable
build:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ ! -s cosign.pub ]]; then
        echo "There is no cosign.pub yet: make your signing key first, as README.md says." >&2
        exit 1
    fi
    podman build --pull=newer --build-arg IMAGE_REPOSITORY="{{ repository }}" \
        --tag "localhost/{{ image_name }}:{{ tag }}" --file Containerfile .

# Lay the image out in layers that change little from one build to the next, so updates stay small (as root)
rechunk:
    #!/usr/bin/bash
    set -euo pipefail
    image="localhost/{{ image_name }}:{{ tag }}"
    storage="$(podman info --format '{{ '{{.Store.GraphRoot}}' }}')"
    # rpm-ostree from the image itself reads the image's tree and writes the result back in its place
    podman run --rm --pull=never --privileged \
        --mount=type=image,src="${image}",target=/chunked-root \
        --mount=type=bind,src="${storage}",target=/run/host-container-storage,rw \
        --mount=type=tmpfs,target=/run/rpm-ostree-storage \
        --entrypoint /usr/bin/rpm-ostree \
        "${image}" \
        compose build-chunked-oci --bootc --format-version=1 --rootfs /chunked-root \
        --output "containers-storage:[overlay@/run/host-container-storage+/run/rpm-ostree-storage]${image}"

# A shell inside the built image, to look around in it
run:
    podman run --rm -it "localhost/{{ image_name }}:{{ tag }}" bash

# Check the format of this file
check:
    just --unstable --fmt --check -f Justfile
