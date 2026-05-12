# Build The ISO

VantaOS Obsidian currently uses an Ubuntu 24.04 LTS ISO remaster flow.

## Build Host

Use Ubuntu 24.04 LTS or a close derivative as the build host.

Install build tools:

```bash
sudo apt update
sudo apt install squashfs-tools xorriso rsync curl
```

## Build Clean

```bash
cd VantaOS/Obsidian
sudo bash ./build/build-iso.sh
```

Output:

```text
out/vantaos-obsidian-24.04-clean-amd64.iso
```

## Build Gamer

```bash
cd VantaOS/Obsidian
sudo VANTAOS_PROFILE=gamer bash ./build/build-iso.sh
```

## Build Work

```bash
cd VantaOS/Obsidian
sudo VANTAOS_PROFILE=work bash ./build/build-iso.sh
```

## Notes

- The default upstream ISO URL points at Ubuntu 24.04 LTS.
- Override with `UBUNTU_ISO_URL` if Canonical publishes a newer 24.04 point release.
- The unified Calamares GUI profile chooser is designed in config, but the reliable first build path is profile-specific ISO generation.
