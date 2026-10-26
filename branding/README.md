# Branding

Put any of these files here, and the image carries them. Leave the folder as it is to keep Amethystora's look.

| File | What it becomes |
|---|---|
| `name` | The system's name, on one line, up to 40 of A to Z, a to z, 0 to 9, spaces and `. + ' -`. Settings' About says "*name*, built on Amethystora". |
| `wallpaper.png`, `.jpg`, `.webp` or `.svg` | Every new account's first wallpaper, whichever theme it picks, and the lock screen's. |
| `logo.png` | A square picture, 256 pixels or more: About's picture, and the logo under the login screen's list of accounts. |
| `login.png` or `.jpg` | The login screen's background. |
| `style` | The desktop style every account starts with, whichever theme it picks: `islands`, `floating`, `hairline`, `capsule`, `terminal`, `segments` or `neon`. |
| `icons` | The icon pack, likewise: `amethystora-glass`, `-glass-light`, `-neon`, `-neon-light`, `-duotone`, `-line`, `-clay`, `-muted` or `-pixel`, or any other icon theme in the image. |
| `font`, `mono-font` | The interface and the monospace font, likewise: a family the image has (`fc-list : family` lists them). |

Each of the last four is one line, and an account's own choice (`ame desktop style`, `icons`, `font`, `mono-font`)
still comes first.

Each file is checked by what it holds, and nothing larger than 30 MB is taken. The boot menu, the boot splash
and the Amethystora apps keep Amethystora's look, and the system still says it is built on Amethystora: its
`os-release` keeps `ID=amethystora`, which the installers go by.

Use only pictures you may use. Never another maker's logo: Fedora's trademark guidelines ask a system built
from Fedora to carry none of Fedora's, and `amethystora-image-check` stops a build that puts Fedora's back.
