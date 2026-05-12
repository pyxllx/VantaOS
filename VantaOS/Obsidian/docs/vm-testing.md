# VM Testing

Recommended first test target: UEFI VM with 4 CPU cores, 6 GB RAM, and 64 GB disk.

## QEMU

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 6144 \
  -smp 4 \
  -machine q35 \
  -cpu host \
  -bios /usr/share/OVMF/OVMF_CODE.fd \
  -cdrom out/vantaos-obsidian-24.04-clean-amd64.iso \
  -drive file=vantaos-test.qcow2,format=qcow2,if=virtio \
  -device virtio-vga-gl \
  -display gtk,gl=on \
  -device intel-hda \
  -device hda-duplex \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0
```

Create a disk first:

```bash
qemu-img create -f qcow2 vantaos-test.qcow2 64G
```

## VirtualBox / VMware

- Use UEFI.
- Give the VM at least 4 GB RAM. Use 6 GB or more for Gamer/Work testing.
- Enable 3D acceleration.
- Test both live boot and installed boot.

## Smoke Test Checklist

- Boots to live desktop.
- Installer opens.
- Wayland session works.
- X11 fallback session exists.
- Networking works.
- Audio works.
- Discover opens.
- Firefox opens.
- Flatpak remote exists after install.
- SDDM login appears after install.
- Shutdown/restart works.
