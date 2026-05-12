#!/usr/bin/env bash
set -euo pipefail

# Post-install helper for installed VantaOS systems.
# Calamares will eventually call this from the target system. For now it is
# usable manually with: sudo VANTAOS_PROFILE=gamer ./post-install.sh

PROFILE="${VANTAOS_PROFILE:-clean}"
PROJECT_DIR="${PROJECT_DIR:-/opt/vantaos/obsidian}"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Project directory not found: $PROJECT_DIR" >&2
  exit 1
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  for flatpak_list in "$PROJECT_DIR/profiles/clean/flatpaks.list" "$PROJECT_DIR/profiles/$PROFILE/flatpaks.list"; do
    [[ -f "$flatpak_list" ]] || continue
    sed 's/#.*//' "$flatpak_list" | awk 'NF {print $1}' |
      xargs -r flatpak install -y flathub
  done
fi

systemctl enable ufw.service || true
ufw --force enable || true

echo "VantaOS post-install complete for profile: $PROFILE"
