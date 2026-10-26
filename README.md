# An image of your own, built on Amethystora

This repository builds a system image `FROM` [Amethystora](https://github.com/iarsslen/amethystora),
with what you add to it, every time you push and once a day. GitHub's own runners build it and publish
it to your account's container registry, signed with a key that only you hold, and Renovate moves it
onto each new Amethystora release. Your machines then follow your image the way they followed
Amethystora's, with its updates, its rollbacks and its signature checks.

Most software does not need any of this. Apps from Flathub, command line tools from Homebrew and
other distributions' packages in containers (`amepkg`) update on their own and cannot break the system,
and `ame setup` keeps the list of them in a file you can apply to any machine. An image of your own is
for what has to be in the system itself: a driver, a system service, a tool every account needs, or the
apps, look and policy every machine of a company or a school starts with.

The editor at [amethystora.org/build](https://amethystora.org/build) writes `setup.json`, `branding/` and
`policy/` for you, from lists of what Amethystora can carry.

## 1. Make your repository

Choose **Use this template** above, then **Create a new repository**. Its name is your image's name,
so keep it short and in lower case.

## 2. Make your signing key

Your image is signed with a key of your own, and your machines take it only with that signature. On
Amethystora, `brew install cosign gh` has both commands, and `gh auth login` connects `gh` to your
account. In a clone of your new repository:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
gh secret set SIGNING_SECRET <cosign.key
git add cosign.pub
git commit -m "Add my signing key"
git push
```

`cosign.key` is the private half: the workflow signs with it from the `SIGNING_SECRET` secret, and it
must never be committed (`.gitignore` keeps it out). Keep a copy somewhere safe. Lost, it means a new
key pair, and telling every machine about the new key. `cosign.pub` is the public half, which the image
and your machines check signatures with. The workflow stops if the two do not belong together.

## 3. Add what you need

Edit [`build_files/build.sh`](build_files/build.sh): it has an example of each thing an image usually
needs, from a Fedora package to a file in `/etc`. Push, and the **Actions** tab shows the build. It
publishes `ghcr.io/<you>/<your-image>:stable`, and `:stable-<date>` for each day's build.

Then make the image public, so that your machines can download it without logging in: on GitHub, your
profile, **Packages**, your image, **Package settings**, **Change visibility**.

### What every machine starts with

Four more places shape the image without a script; `build_files/files.sh` reads them after `build.sh`, and
stops the build, saying why, on anything the image cannot take:

- [`packages`](packages): Fedora's packages the system itself carries, one name a line, from Fedora's own
  repositories, such as a printer's driver or a VPN client.
- [`setup.json`](setup.json): the apps from Flathub, the Homebrew tools, the GNOME extensions turned on, the
  theme, the dock, keybindings, the window layout and the tiling's settings every account starts with, in the
  format `ame setup save` writes. Set one machine up as every machine should be, save it there with
  `ame setup save setup.json` and commit it: the build takes it as the image's defaults (`amethystora-setup
  bake`). Accounts can still change everything; containers are left out, since each account makes its own.
- [`branding/`](branding/README.md): the system's name, wallpaper, logo and login screen, and the desktop style,
  icons and fonts every account starts with.
- [`policy/`](policy/README.md): how far the AI agent may go; Security's profile and each of its switches; the
  stricter hardening; GNOME's settings, by default or locked for everyone (screen lock and idle times, the login
  screen's notice, camera and microphone, printing, keyboard layouts and more); and when machines update.

## 4. Stay on Amethystora's newest release

The `FROM` line of the [`Containerfile`](Containerfile) names Amethystora's image by its digest, so
that each build starts from exactly the image it says. Install [Renovate](https://github.com/apps/renovate)
on your repository: when Amethystora publishes a new release, it opens a pull request that moves the
digest, merges it once your image has built on it, and the build after the merge publishes your image
on the new release. Before every build, the workflow checks Amethystora's signature on the image it
builds on, with `amethystora.pub`.

## 5. Switch a machine to it

Amethystora checks the signature of every update. Your image is signed with your key, not Amethystora's,
so tell the machine about your key first, then switch:

```bash
ame system trust-image ghcr.io/<you>/<your-image> cosign.pub
sudo bootc switch --enforce-container-sigpolicy ghcr.io/<you>/<your-image>:stable
systemctl reboot
```

Without the first command, the machine would take your image whether it is signed or not. Your image
says the same of itself while it is built, so its updates are checked against your key from then on.
Once the machine runs your image, give the signature policy back to the image, so that later changes
to it arrive with your updates rather than staying as they were on the day you switched:

```bash
sudo cp /usr/etc/containers/policy.json /etc/containers/policy.json
```

If you have layered packages, switch with
`sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/<you>/<your-image>:stable` instead, which
keeps them. Going back works the same way, with `ghcr.io/iarsslen/amethystora:stable`.

## 6. ISOs to install it with

Once your image is published, **Actions**, **Build ISO**, **Run workflow** builds its two ISOs with
Amethystora's own installer files: `<your-image>.iso`, which starts from a USB stick to try the system and
installs it from there, offline, and `<your-image>-non-uefi.iso`, the installer, the only one that also starts
computers without UEFI. Either installs your image and switches the machine to take its updates from your
registry, checked against your key. They take about an hour.

Each ISO comes with its checksum, signed with your key (`cosign verify-blob --key cosign.pub --bundle
<iso>.sha256.bundle <iso>.sha256`), and both are kept as the run's artifacts for a week: a GitHub Release
takes no file over 2 GiB. To keep them for longer, set four more secrets for S3-compatible storage, such as
Cloudflare R2, and each run uploads them there: `STORAGE_ENDPOINT` (such as
`https://<account>.r2.cloudflarestorage.com`), `STORAGE_BUCKET`, `STORAGE_ACCESS_KEY_ID` and
`STORAGE_SECRET_ACCESS_KEY`.

## Building on your own machine

Amethystora has `podman` and `just`:

```bash
just build        # builds localhost/<your-image>:stable
just run          # a shell inside it
sudo just rechunk # lays it out in layers that keep updates small, as the workflow does
```

## What the build checks

The `Containerfile` ends with two checks, and a build that fails either is not published:

- `amethystora-image-check`, which comes with Amethystora, fails if a step undid something Amethystora
  relies on: the checking of updates, the `ame` commands, or the absence of Fedora's logo and release
  packages, which Fedora's trademark guidelines ask a remix not to carry.
- `bootc container lint` checks that the image is one bootc can install and update.

## Another image or stream

To build on the developer image, or on the one with NVIDIA's driver, change the `FROM` line to
`amethystora-dx`, `amethystora-nvidia-open` or `amethystora-dx-nvidia-open`, with its own digest:
`skopeo inspect docker://ghcr.io/iarsslen/amethystora-dx:stable | jq -r .Digest`. The `latest` tag
follows Amethystora's testing stream.

## A recipe instead of a script

If you would rather describe your image in a file than in a script, [BlueBuild](https://blue-build.org)
builds from any bootc image: give its `recipe.yml` `base-image: ghcr.io/iarsslen/amethystora` and
`image-version: stable`.

## Licence

Apache-2.0, as Amethystora is: see [LICENSE](LICENSE). The layout follows Universal Blue's
[image-template](https://github.com/ublue-os/image-template), also Apache-2.0.
