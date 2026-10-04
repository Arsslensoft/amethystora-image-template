#!/usr/bin/bash
# What your image adds to Amethystora. It runs once, as root, while the image is built: install
# packages, add files, turn services on. Everything else of Amethystora is there already.
#
# Most software does not need to be in the image, and is better off outside it: apps from Flathub,
# command line tools from Homebrew, and other distributions' packages in containers (amepkg) all
# update on their own and cannot break the system. This is for what has to be in the system itself,
# such as a driver, a system service, or a tool every account on the machine needs.

set -euo pipefail

# A package from Fedora's repositories:
#
# dnf5 -y install tmux

# A package from a Copr project. Its repository is turned on for this one install only, so that it
# can never replace a Fedora package of the same name later on:
#
# dnf5 -y copr enable someone/project
# dnf5 -y copr disable someone/project
# dnf5 -y install --enablerepo="copr:copr.fedorainfracloud.org:someone:project" some-package

# A systemd service, on from the first boot:
#
# systemctl enable podman.socket

# A file in /etc. The image's /etc is what a new machine starts with, and an update brings a change
# to it to every machine that has not changed that file itself:
#
# cat >/etc/sysctl.d/90-my-image.conf <<'EOF'
# vm.swappiness = 10
# EOF
