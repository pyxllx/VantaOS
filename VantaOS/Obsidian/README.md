# VantaOS Obsidian

VantaOS Obsidian is the first planned release of VantaOS: an Ubuntu 24.04
LTS-based KDE Plasma distribution focused on polish, speed, gaming readiness,
creator friendliness, and beginner-friendly defaults without hiding advanced
control.

This repository is intentionally practical. It starts from Ubuntu 24.04 LTS,
uses KDE Plasma, keeps Wayland as the default with X11 fallback, uses Calamares
for installation, and wraps proven Linux tools instead of reinventing the
desktop.

## Current Status

Implemented in this folder:

- Project structure under `VantaOS/Obsidian`.
- Ubuntu 24.04 ISO remaster script.
- Chroot customization script.
- Clean, Gamer, Work, and Optional package manifests.
- Gamer profile includes OBS Studio.
- Calamares first-pass configuration.
- KDE Plasma default config stubs.
- SDDM and Plymouth config locations.
- Branding asset locations and starter SVG logo.
- Documentation for building, VM testing, hardware install, branding, roadmap, and package policy.
- Planned app folders for Gaming Center, Work Center, and Security Center.

Still planned:

- Validated bootable ISO output.
- Fully tested Calamares profile chooser.
- Real SDDM theme.
- Rendered Plymouth bitmap assets.
- Final wallpapers.
- VantaOS Center applications.
- Themed Discover/System Monitor polish.
- Hardware validation matrix.
- Debian package build automation for VantaOS metapackages.

## Release Stack

- Base: Ubuntu 24.04 LTS.
- Desktop: KDE Plasma.
- Display: Wayland default, X11 fallback.
- Installer: Calamares.
- Store: Discover plus Flatpak/Flathub.
- Password manager: KeePassXC default, Bitwarden optional.
- TOTP: GNOME Authenticator or equivalent.
- RGB: OpenRGB default for Gamer, SignalRGB optional/planned.
- Resource monitor: Plasma System Monitor default, Mission Center optional.
- Live wallpapers: existing tools only, such as `wallpaper-engine-kde-plugin` or `mpvpaper`.

## Profiles

### Clean Install

Essentials only:

- Firefox.
- Dolphin.
- Konsole.
- KDE System Settings.
- Discover.
- Plasma System Monitor.
- Ark.
- Spectacle.
- Gwenview.
- Okular.
- Networking, Bluetooth, audio, display, storage, and power tools.
- KeePassXC.
- TOTP app.
- Firewall controls.

No gaming apps, office suite, communication apps, or development tools.

### Gamer

Clean plus:

- Steam.
- Heroic Games Launcher.
- Lutris.
- ProtonUp-Qt.
- Wine and Winetricks.
- MangoHud.
- GameMode.
- vkBasalt.
- OpenRGB.
- OBS Studio.
- Discord.
- VSCodium.
- Controller tools.
- GPU monitoring/control tools where available.

Gamescope is tracked as optional/planned for Ubuntu 24.04 because it is not a
safe default repository dependency for the first Obsidian build.

### Work

Clean plus:

- LibreOffice.
- Thunderbird.
- Calendar tools.
- PDF tooling.
- Screenshot and screen recording.
- Archive manager.
- Calculator.
- Remmina.
- Printer/scanner support.
- Timeshift.
- VSCodium.
- Optional Flatpak candidates: Zoom, Slack, OnlyOffice, Obsidian.

## Main Menu Direction

VantaOS 1.0 uses KDE's launcher as the foundation. The Super key should open a
dark, search-first launcher with profile-aware favorites. This keeps the first
release stable while still giving VantaOS its own polished command-center feel.

No custom launcher is planned for 1.0.

## Build

Build the Clean ISO on an Ubuntu 24.04 host:

```bash
cd VantaOS/Obsidian
sudo bash ./build/build-iso.sh
```

Build the Gamer ISO:

```bash
cd VantaOS/Obsidian
sudo VANTAOS_PROFILE=gamer bash ./build/build-iso.sh
```

Build the Work ISO:

```bash
cd VantaOS/Obsidian
sudo VANTAOS_PROFILE=work bash ./build/build-iso.sh
```

See `docs/build-iso.md` for details.

## Design Boundaries

VantaOS 1.0 does not build:

- A custom desktop environment.
- A custom compositor.
- A custom settings framework.
- A custom package manager.
- A custom live wallpaper renderer.
- A custom password manager.
- A custom GPU/fan/RGB backend.

Instead, VantaOS wraps and themes proven tools so the system feels cohesive
without becoming impossible to maintain.

## Next Work

1. Run manifest validation.
2. Test Clean ISO build on Ubuntu 24.04.
3. Fix package names that differ across Ubuntu repositories.
4. Boot Clean ISO in a VM.
5. Validate Calamares install.
6. Add real SDDM/Plymouth/wallpaper assets.
7. Wire profile selection reliably in Calamares.
8. Start lightweight VantaOS Center launchers.
