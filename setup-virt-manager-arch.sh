#!/usr/bin/env bash
set -e

sudo pacman -S --needed qemu-full virt-manager libvirt edk2-ovmf dnsmasq swtpm iptables-nft
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"

echo "Done. Log out and back in or just reboot for the group change to take effect."
