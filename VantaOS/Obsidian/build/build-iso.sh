#!/usr/bin/env bash
set -euo pipefail

# VantaOS Obsidian ISO remaster script.
#
# This intentionally starts from the official Ubuntu 24.04 LTS desktop ISO
# instead of constructing a distro image from scratch. It keeps the first
# release practical: boot Ubuntu, install VantaOS packages/configs, rebuild.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$PROJECT_ROOT/work}"
OUT_DIR="${OUT_DIR:-$PROJECT_ROOT/out}"
PROFILE="${VANTAOS_PROFILE:-clean}"
ARCH="${ARCH:-amd64}"
ISO_LABEL="${ISO_LABEL:-VantaOS_Obsidian}"
UBUNTU_ISO_URL="${UBUNTU_ISO_URL:-https://releases.ubuntu.com/24.04/ubuntu-24.04.4-desktop-amd64.iso}"
UBUNTU_ISO="${UBUNTU_ISO:-$WORK_DIR/ubuntu-24.04-desktop-$ARCH.iso}"
EXTRACT_DIR="$WORK_DIR/iso"
CHROOT_DIR="$WORK_DIR/chroot"
OUTPUT_ISO="$OUT_DIR/vantaos-obsidian-24.04-$PROFILE-$ARCH.iso"

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "This script must run as root because it mounts filesystems and enters chroot." >&2
    exit 1
  fi
}

require_tools() {
  local missing=()
  local tools=(chroot rsync unsquashfs mksquashfs xorriso sed awk mount umount)

  if command -v curl >/dev/null 2>&1; then
    DOWNLOADER=(curl -L --fail --output)
  elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER=(wget -O)
  else
    missing+=(curl-or-wget)
  fi

  for tool in "${tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done

  if ((${#missing[@]})); then
    echo "Missing required tools: ${missing[*]}" >&2
    echo "On Ubuntu: sudo apt install squashfs-tools xorriso rsync curl" >&2
    exit 1
  fi
}

validate_profile() {
  if [[ ! -f "$PROJECT_ROOT/profiles/$PROFILE/packages.list" ]]; then
    echo "Unknown profile '$PROFILE'. Expected one of: clean, gamer, work." >&2
    exit 1
  fi
}

download_iso() {
  mkdir -p "$WORK_DIR" "$OUT_DIR"
  if [[ -f "$UBUNTU_ISO" ]]; then
    echo "Using existing ISO: $UBUNTU_ISO"
    return
  fi

  echo "Downloading Ubuntu 24.04 LTS ISO..."
  "${DOWNLOADER[@]}" "$UBUNTU_ISO" "$UBUNTU_ISO_URL"
}

extract_iso() {
  rm -rf "$EXTRACT_DIR" "$CHROOT_DIR"
  mkdir -p "$EXTRACT_DIR" "$CHROOT_DIR"

  echo "Extracting ISO filesystem..."
  xorriso -osirrox on -indev "$UBUNTU_ISO" -extract / "$EXTRACT_DIR" >/dev/null

  chmod -R u+w "$EXTRACT_DIR"

  local squashfs="$EXTRACT_DIR/casper/filesystem.squashfs"
  if [[ ! -f "$squashfs" ]]; then
    echo "Could not find casper/filesystem.squashfs in the Ubuntu ISO." >&2
    exit 1
  fi

  echo "Unpacking live filesystem..."
  unsquashfs -d "$CHROOT_DIR" "$squashfs" >/dev/null
}

mount_chroot() {
  mount --bind /dev "$CHROOT_DIR/dev"
  mount --bind /run "$CHROOT_DIR/run"
  mount -t proc proc "$CHROOT_DIR/proc"
  mount -t sysfs sys "$CHROOT_DIR/sys"
  mount -t devpts devpts "$CHROOT_DIR/dev/pts"
  cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"
}

unmount_chroot() {
  set +e
  umount -lf "$CHROOT_DIR/dev/pts" 2>/dev/null
  umount -lf "$CHROOT_DIR/sys" 2>/dev/null
  umount -lf "$CHROOT_DIR/proc" 2>/dev/null
  umount -lf "$CHROOT_DIR/run" 2>/dev/null
  umount -lf "$CHROOT_DIR/dev" 2>/dev/null
  set -e
}

copy_project_into_chroot() {
  mkdir -p "$CHROOT_DIR/opt/vantaos/obsidian"
  rsync -a --delete \
    --exclude work \
    --exclude out \
    --exclude .git \
    "$PROJECT_ROOT/" "$CHROOT_DIR/opt/vantaos/obsidian/"
}

customize_chroot() {
  echo "Customizing live filesystem for profile: $PROFILE"
  mount_chroot
  trap unmount_chroot EXIT

  chroot "$CHROOT_DIR" /usr/bin/env \
    VANTAOS_PROFILE="$PROFILE" \
    DEBIAN_FRONTEND=noninteractive \
    /bin/bash /opt/vantaos/obsidian/build/chroot-setup.sh

  unmount_chroot
  trap - EXIT
}

refresh_manifests() {
  echo "Refreshing ISO manifests..."
  chroot "$CHROOT_DIR" dpkg-query -W --showformat='${Package} ${Version}\n' \
    > "$EXTRACT_DIR/casper/filesystem.manifest"
  cp "$EXTRACT_DIR/casper/filesystem.manifest" "$EXTRACT_DIR/casper/filesystem.manifest-desktop"

  printf '%s' "$(du -sx --block-size=1 "$CHROOT_DIR" | awk '{print $1}')" \
    > "$EXTRACT_DIR/casper/filesystem.size"
}

rebuild_squashfs() {
  echo "Rebuilding squashfs..."
  rm -f "$EXTRACT_DIR/casper/filesystem.squashfs"
  mksquashfs "$CHROOT_DIR" "$EXTRACT_DIR/casper/filesystem.squashfs" \
    -comp xz -b 1M -noappend
}

brand_boot_menu() {
  echo "Applying boot menu labels..."
  find "$EXTRACT_DIR" -type f \( -name '*.cfg' -o -name '*.txt' \) -print0 \
    | xargs -0 sed -i 's/Ubuntu/VantaOS Obsidian/g; s/Try or Install VantaOS Obsidian/Try or Install VantaOS Obsidian/g'
}

rebuild_iso() {
  echo "Building ISO: $OUTPUT_ISO"
  rm -f "$OUTPUT_ISO"

  (
    cd "$EXTRACT_DIR"
    xorriso -as mkisofs \
      -r -V "$ISO_LABEL" \
      -o "$OUTPUT_ISO" \
      --grub2-mbr boot/grub/i386-pc/boot_hybrid.img \
      -partition_offset 16 \
      --mbr-force-bootable \
      -append_partition 2 0xef boot/grub/efi.img \
      -appended_part_as_gpt \
      -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
      -c boot.catalog \
      -b boot/grub/i386-pc/eltorito.img \
      -no-emul-boot -boot-load-size 4 -boot-info-table \
      --grub2-boot-info \
      -eltorito-alt-boot \
      -e '--interval:appended_partition_2:::' \
      -no-emul-boot \
      .
  )

  echo "Done: $OUTPUT_ISO"
}

main() {
  require_root
  require_tools
  validate_profile
  download_iso
  extract_iso
  copy_project_into_chroot
  customize_chroot
  refresh_manifests
  rebuild_squashfs
  brand_boot_menu
  rebuild_iso
}

main "$@"
