#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/opt/vantaos/obsidian"
PROFILE="${VANTAOS_PROFILE:-clean}"
PROFILE_DIR="$PROJECT_DIR/profiles/$PROFILE"

read_packages() {
  local file="$1"
  sed 's/#.*//' "$file" | awk 'NF {print $1}'
}

install_package_list() {
  local file="$1"
  if [[ -f "$file" ]]; then
    mapfile -t packages < <(read_packages "$file")
    if ((${#packages[@]})); then
      apt-get install -y --no-install-recommends "${packages[@]}"
    fi
  fi
}

enable_ubuntu_repos() {
  apt-get update
  apt-get install -y --no-install-recommends software-properties-common ca-certificates gnupg
  add-apt-repository -y universe || true
  add-apt-repository -y multiverse || true
  add-apt-repository -y restricted || true
}

install_flatpak_remotes() {
  if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
}

install_flatpak_list() {
  local file="$1"
  if command -v flatpak >/dev/null 2>&1 && [[ -f "$file" ]]; then
    sed 's/#.*//' "$file" | awk 'NF {print $1}' |
      xargs -r flatpak install --system -y flathub
  fi
}

copy_system_configs() {
  install -d /etc/calamares /etc/calamares/modules
  cp -a "$PROJECT_DIR/config/calamares/." /etc/calamares/

  install -d /etc/sddm.conf.d
  cp -a "$PROJECT_DIR/config/sddm/." /etc/sddm.conf.d/

  install -d /usr/share/plymouth/themes/vantaos
  cp -a "$PROJECT_DIR/branding/plymouth/vantaos/." /usr/share/plymouth/themes/vantaos/
  cp -f "$PROJECT_DIR/config/plymouth/vantaos.plymouth" /usr/share/plymouth/themes/vantaos/vantaos.plymouth

  install -d /usr/share/wallpapers/vantaos
  cp -a "$PROJECT_DIR/branding/wallpapers/." /usr/share/wallpapers/vantaos/

  install -d /etc/skel/.config
  cp -a "$PROJECT_DIR/config/plasma/." /etc/skel/.config/
}

set_defaults() {
  echo "vantaos" > /etc/hostname
  printf '127.0.1.1\tvantaos\n' >> /etc/hosts

  if command -v update-alternatives >/dev/null 2>&1 && [[ -f /usr/share/plymouth/themes/vantaos/vantaos.plymouth ]]; then
    update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth \
      /usr/share/plymouth/themes/vantaos/vantaos.plymouth 90 || true
    update-alternatives --set default.plymouth /usr/share/plymouth/themes/vantaos/vantaos.plymouth || true
    update-initramfs -u || true
  fi

  systemctl enable sddm.service || true
  systemctl set-default graphical.target || true
}

cleanup_image() {
  apt-get autoremove -y
  apt-get clean
  rm -rf /var/lib/apt/lists/*
  rm -rf /tmp/* /var/tmp/*
  truncate -s 0 /etc/machine-id || true
}

main() {
  if [[ ! -d "$PROFILE_DIR" ]]; then
    echo "Missing profile directory: $PROFILE_DIR" >&2
    exit 1
  fi

  enable_ubuntu_repos
  apt-get update

  install_package_list "$PROJECT_DIR/profiles/clean/packages.list"
  if [[ "$PROFILE" != "clean" ]]; then
    install_package_list "$PROFILE_DIR/packages.list"
  fi

  install_flatpak_remotes
  install_flatpak_list "$PROJECT_DIR/profiles/clean/flatpaks.list"
  if [[ "$PROFILE" != "clean" ]]; then
    install_flatpak_list "$PROFILE_DIR/flatpaks.list"
  fi
  copy_system_configs
  set_defaults
  cleanup_image
}

main "$@"
