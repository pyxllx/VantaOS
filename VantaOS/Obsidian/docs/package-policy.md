# Package Policy

VantaOS Obsidian uses conservative package sources.

Priority order:

1. Ubuntu 24.04 LTS repositories.
2. Flatpak from Flathub for apps that need faster delivery or are not packaged well in Ubuntu.
3. External repositories only after maintainability review.

## Defaults

- KeePassXC default.
- Bitwarden optional.
- OpenRGB default in Gamer.
- SignalRGB optional/planned.
- Plasma System Monitor default.
- Mission Center optional.
- VSCodium default in Gamer and Work through Flatpak unless a maintained repository is added later.
- LibreOffice default in Work.
- OnlyOffice optional.
- OBS Studio default in Gamer and Work.
- Gamescope optional/planned on Ubuntu 24.04 until the package source is reliable.

Optional apps such as Zoom, Slack, OnlyOffice, Obsidian, and Bitwarden should
stay out of default profiles until Calamares toggles are fully wired.

## Bloat Rule

Clean profile must stay genuinely clean.

No office suite, gaming apps, communication apps, or development tools in Clean.
