#!/usr/bin/bash
# What setup.json, branding/ and policy/ say, made part of the image. It runs after build.sh, so that an
# extension build.sh installs can be turned on in setup.json, and each part is left out while its file or
# folder says nothing. You do not need to edit this: edit those files, by hand or with the editor on
# amethystora.org.
#
#   setup.json          the apps, extensions, theme, dock, keybindings and window layout every account starts
#                       with, in the format `ame setup save` writes (amethystora-setup bake)
#   branding/           the system's name, wallpaper, logo and login screen (amethystora-brand)
#   policy/agent.conf   how far the AI agent may go on every machine: ALLOW, ALLOW_FOR and ROOT lines
#   policy/security     one word, the security profile every machine starts with: off, default, light,
#                       balanced or thorough

set -euo pipefail

# The Amethystora this builds on has to know how: Renovate moves it onto each new release
need() {
    [[ -x "$1" ]] || {
        echo "files.sh: the Amethystora image this builds FROM has no $1 yet: merge Renovate's update of the FROM line." >&2
        exit 1
    }
}

if jq -e 'del(.version) != {}' /ctx/setup.json >/dev/null; then
    need /usr/libexec/amethystora-setup
    /usr/libexec/amethystora-setup bake /ctx/setup.json
fi

if find /ctx/branding -mindepth 1 -maxdepth 1 ! -name '*.md' ! -name .gitkeep | grep -q .; then
    need /usr/libexec/amethystora-brand
    /usr/libexec/amethystora-brand /ctx/branding
fi

# Read strictly, as the agent reads it: a line it cannot read would count as the strictest there is, which
# is safe but not what was meant, so the build stops on one instead
if [[ -f /ctx/policy/agent.conf ]]; then
    bad="$(grep -vxE '[[:space:]]*(#.*)?|ALLOW=(act|know|off)|ALLOW_FOR=[A-Za-z0-9_.@$\\-]+:(act|know|off)|ROOT=(session|minutes|each|terminal)' \
        /ctx/policy/agent.conf || true)"
    if [[ -n "${bad}" ]]; then
        printf 'files.sh: policy/agent.conf has lines the agent does not read:\n%s\n' "${bad}" >&2
        exit 1
    fi
    install -Dm0644 /ctx/policy/agent.conf /etc/amethystora/agent.conf
fi

if [[ -f /ctx/policy/security ]]; then
    profile="$(tr -d '[:space:]' </ctx/policy/security)"
    case "${profile}" in
        off | default | light | balanced | thorough) ;;
        *) echo "files.sh: policy/security is one of off, default, light, balanced and thorough, not \"${profile}\"." >&2; exit 1 ;;
    esac
    # The note it keeps of who changed what belongs to a machine, not to the image
    AMETHYSTORA_SECURITY_NOTES=/tmp/security-notes /usr/libexec/amethystora-security-config profile "${profile}"
fi
