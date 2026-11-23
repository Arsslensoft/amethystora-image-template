#!/usr/bin/bash
# What packages, setup.json, branding/ and policy/ say, made part of the image. It runs after build.sh, and each
# part is left out while its file or folder says nothing. You do not need to edit this: edit those files, by hand
# or with the editor on amethystora.org.
#
#   packages     Fedora's packages the image carries, one name a line, from Fedora's own repositories only
#                (first, so that setup.json can turn on an extension one of them installs)
#   setup.json   the apps, extensions, theme, dock, keybindings, window layout and tiling every account starts
#                with, in the format `ame setup save` writes (amethystora-setup bake)
#   branding/    the system's name, wallpaper, logo, login screen, desktop style, icons and fonts
#                (amethystora-brand)
#   policy/      how far the AI agent may go, Security's profile and switches, the stricter hardening, GNOME's
#                settings by default or locked, when the image updates itself, the company's proxy, DNS servers,
#                VPN connections and Flatpak remotes (amethystora-image-policy)

set -euo pipefail

# The Amethystora this builds on has to know how: Renovate moves it onto each new release
need() {
    [[ -x "$1" ]] || {
        echo "files.sh: the Amethystora image this builds FROM has no $1 yet: merge Renovate's update of the FROM line." >&2
        exit 1
    }
}
# A file or folder that says something: more than comments, blank lines and Markdown
says() { find "$1" -maxdepth 1 -type f ! -name '*.md' ! -name .gitkeep -exec grep -lvE '^[[:space:]]*(#|$)' {} + 2>/dev/null | grep -q .; }

if says /ctx/packages; then
    mapfile -t packages < <(grep -vE '^[[:space:]]*(#|$)' /ctx/packages | tr -d '\r' | sed 's/[[:space:]]*$//')
    for name in "${packages[@]}"; do
        [[ "${name}" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]*$ ]] || { echo "files.sh: packages: \"${name}\" is not a package's name." >&2; exit 1; }
    done
    # Fedora's repositories by name: no Copr or other repository can stand in for a package of Fedora's, whose
    # source Fedora keeps
    dnf5 -y install --repo=fedora --repo=updates "${packages[@]}"
    rm -rf /run/dnf
fi

# The company's own Flatpak remotes first, so that setup.json may name their apps
if [[ -d /ctx/policy/flatpak-remotes ]] && says /ctx/policy/flatpak-remotes; then
    need /usr/libexec/amethystora-image-policy
    /usr/libexec/amethystora-image-policy /ctx/policy --only flatpak-remotes
fi

if jq -e 'del(.version) != {}' /ctx/setup.json >/dev/null; then
    need /usr/libexec/amethystora-setup
    /usr/libexec/amethystora-setup bake /ctx/setup.json
fi

if says /ctx/branding; then
    need /usr/libexec/amethystora-brand
    /usr/libexec/amethystora-brand /ctx/branding
fi

# vpn/ is a folder of its own, so a policy of VPN connections alone has nothing at the top of policy/
if says /ctx/policy || says /ctx/policy/vpn; then
    need /usr/libexec/amethystora-image-policy
    /usr/libexec/amethystora-image-policy /ctx/policy
fi
