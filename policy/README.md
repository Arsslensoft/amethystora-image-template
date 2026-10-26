# Policy

What every machine running the image starts with. Leave the folder as it is to keep Amethystora's defaults. Each
file is read strictly: the build stops on a line it cannot take, and says why.

## `agent.conf`

How far the AI agent may go, for every account: the file Amethystora reads from `/etc/amethystora/agent.conf`.

```text
# The most any account may turn on: act (the agent may make changes, asking each time), know (it may only read), off
ALLOW=know
# One account's own limit instead, one line each
ALLOW_FOR=admin:act
# How the agent's commands as root are allowed: session, minutes, each or terminal
ROOT=each
```

A machine's administrator can still change it with `ame agent lock` and `ame agent root`.

## `security`

The security profile every machine starts with, on its own first line: `off`, `default`, `light`, `balanced` or
`thorough` (`ame security profile` describes each). Then any single switch, as `ame security settings` lists them:

```text
balanced
PROCESSES=on
NOTIFY=critical
```

No profile turns on anything that sends something away from the machine; a switch that does (`OSPREY`, `TRIAGE`,
`REPUTATION`) is yours to name, after reading what `ame security settings` says it sends.

## `hardening`

The stricter settings, one `NAME on` a line, as `ame security` turns each on: `kernel strict`, `time`,
`network-daemons`, `block-bluetooth`, `block-webcam`, `block-automount`, `block-user-extensions`, `block-xwayland`,
`flatpak-password`, `noexec-temp`, `no-coredumps`, `package-cooldown on` or `strict`, `brew-attestations`,
`audit-locked` and, on the developer images, `vscodium-extensions`. And what the machine sends by itself, turned
off: `countme off`, `connectivity-check off`, `firmware-metadata off`. The rest need a machine to set them.

## `desktop.json`

GNOME's settings every account starts with, each one also lockable so that no account can change it:

```json
{
  "version": 1,
  "set": {"idle-delay": 300, "screen-lock": true, "camera-off": true, "keyboard-layouts": ["us", "fr+azerty"],
          "login-banner": "Property of Acme. Authorised use only."},
  "lock": ["idle-delay", "screen-lock"],
  "extensions-off": ["amethystora-widgets@iarsslen.github.io"]
}
```

The settings are `screen-lock`, `lock-delay` and `idle-delay` (seconds), `sleep-on-mains` and `sleep-on-battery`
(seconds, 0 never), `lock-screen-notifications`, `user-switching-off`, `printing-off`, `print-setup-off`,
`camera-off`, `microphone-off`, `recent-files`, `location`, `automatic-timezone`, `clock-format` (`24h` or `12h`),
`hot-corners`, `keyboard-layouts` (up to eight, such as `us` or `de+nodeadkeys`), and the login screen's
`login-user-list-off` and `login-banner`, which are not locked. `extensions-off` turns off extensions the image
carries, Amethystora UI aside.

## The company's network

Your image is usually public: anyone who can download it can read every file in it. So nothing here may hold a
password, a key or a login. The build stops on one.

### `proxy`

```text
http=proxy.acme.example:3128
https=proxy.acme.example:3128
ignore=localhost,127.0.0.0/8,*.acme.example
# Locked: no account can change GNOME's proxy settings
lock=yes
```

GNOME's apps follow GNOME's proxy settings, and what a session starts (a terminal and its tools) the
`http_proxy` variables beside them. A proxy that asks for a login asks each person.

### `dns`

```text
servers=10.0.0.53#dns.acme.example 10.0.1.53#dns.acme.example
```

Every name the machines look up goes to these servers over DNS-over-TLS, as `ame security dns` sends them to a
public resolver: each `ADDRESS#NAME`, the name being the one the server's certificate is for. A network's and a
VPN's own names still go to their own servers.

### `flatpak-remotes/`

A Flatpak repository of the company's, as `NAME.flatpakrepo` (https only, with its `GPGKey`) and `NAME.fingerprint`,
the fingerprint of that key on one line, which the build checks the key against. `setup.json` may then name the
remote's apps (`"origin": "NAME"`), which every machine installs from the `stable` branch.

### `vpn/`

NetworkManager connections, as `NAME.nmconnection` (keyfile, as `/etc/NetworkManager/system-connections` holds
them), of a VPN plugin the image carries (OpenVPN, OpenConnect, vpnc, Fortinet SSL, L2TP, Libreswan, SSTP) or
WireGuard, and the CA certificates they name, each as `/etc/pki/amethystora-vpn/FILE.crt`. No password, private key,
pre-shared key or key file: NetworkManager asks each person for those as they connect, and keeps them in their
keyring. WireGuard's private key is each machine's own, added in Settings.

## `updates`

```text
# Automatic updates on or off, and when they run (a systemd time: "daily", "Sat 03:00", "Mon..Fri 12:30")
automatic=on
when=Sat 03:00
```
