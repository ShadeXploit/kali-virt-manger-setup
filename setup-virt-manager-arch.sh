#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: setup-virt-manager-arch.sh [options]

Sets up virt-manager/libvirt on Arch Linux.

Options:
  --download-kali-image      Download and extract the latest Kali QEMU image
  --kali-url URL             Use a specific Kali QEMU image URL (.7z)
  --images-dir DIR           Destination directory for extracted Kali image
                             (default: ~/VMImages/kali)
  --dry-run                  Print commands without running them
  -h, --help                 Show this help
USAGE
}

DRY_RUN=false
DOWNLOAD_KALI_IMAGE=false
KALI_URL=""

if [[ $# -gt 0 ]]; then
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --download-kali-image)
        DOWNLOAD_KALI_IMAGE=true
        shift
        ;;
      --kali-url)
        if [[ -z "${2:-}" ]]; then
          echo "--kali-url requires a value." >&2
          exit 1
        fi
        KALI_URL="$2"
        shift 2
        ;;
      --images-dir)
        if [[ -z "${2:-}" ]]; then
          echo "--images-dir requires a value." >&2
          exit 1
        fi
        IMAGES_DIR_OVERRIDE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 1
        ;;
    esac
  done
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "This script is intended for Arch Linux systems with pacman." >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [[ -z "$TARGET_HOME" ]]; then
  TARGET_HOME="$HOME"
fi
IMAGES_DIR="${IMAGES_DIR_OVERRIDE:-$TARGET_HOME/VMImages/kali}"

run_cmd() {
  if [[ "$DRY_RUN" == true ]]; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

run_root() {
  if [[ "$EUID" -eq 0 ]]; then
    run_cmd "$@"
  else
    run_cmd sudo "$@"
  fi
}

discover_kali_url() {
  local listing kali_file
  listing="$(curl -fsSL https://cdimage.kali.org/current/)"
  kali_file="$(printf '%s' "$listing" | grep -Eo 'kali-linux-[^"]+-qemu-amd64\.7z' | head -n1 || true)"

  if [[ -z "$kali_file" ]]; then
    echo "Could not auto-discover Kali QEMU image URL. Use --kali-url." >&2
    exit 1
  fi

  printf 'https://cdimage.kali.org/current/%s\n' "$kali_file"
}

echo "Installing virt-manager/libvirt package set..."
run_root pacman -S --needed qemu-full virt-manager libvirt edk2-ovmf dnsmasq swtpm bridge-utils iptables-nft

echo "Enabling libvirtd service..."
run_root systemctl enable --now libvirtd

echo "Adding $TARGET_USER to libvirt group..."
run_root usermod -aG libvirt "$TARGET_USER"

if [[ "$DOWNLOAD_KALI_IMAGE" == true ]]; then
  echo "Installing download/extract helpers (curl, 7zip)..."
  run_root pacman -S --needed curl 7zip

  if [[ -z "$KALI_URL" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      KALI_URL="https://cdimage.kali.org/current/<latest-kali-qemu-amd64.7z>"
    else
      KALI_URL="$(discover_kali_url)"
    fi
  fi

  mkdir -p "$IMAGES_DIR"
  ARCHIVE_PATH="$IMAGES_DIR/$(basename "$KALI_URL")"

  echo "Downloading Kali QEMU image: $KALI_URL"
  run_cmd curl -fL --continue-at - -o "$ARCHIVE_PATH" "$KALI_URL"

  echo "Extracting Kali image into: $IMAGES_DIR"
  run_cmd 7z x -y "$ARCHIVE_PATH" "-o$IMAGES_DIR"
fi

echo
echo "Done. Log out/in (or reboot) so new libvirt group membership applies."
