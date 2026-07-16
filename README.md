# kali-virt-manager-setup

A simple script to automate virt-manager + libvirt setup on Arch Linux and optionally download/extract a Kali QEMU image.

## Usage

```bash
chmod +x ./setup-virt-manager-arch.sh
./setup-virt-manager-arch.sh
```

This runs the requested base setup:

```bash
sudo pacman -S qemu-full virt-manager libvirt edk2-ovmf dnsmasq swtpm bridge-utils iptables-nft
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
```

## Optional: pull Kali QEMU image and extract

```bash
./setup-virt-manager-arch.sh --download-kali-image
```

By default, it auto-detects the latest QEMU image from `https://cdimage.kali.org/current/`, downloads it, and extracts it into `~/VMImages/kali`.

You can override the URL/path:

```bash
./setup-virt-manager-arch.sh --download-kali-image --kali-url "https://cdimage.kali.org/current/kali-linux-2026.2-qemu-amd64.7z" --images-dir "$HOME/VMImages/kali"
```

## Small additions that can help

- `--needed` is used with `pacman -S` to avoid reinstalling already-installed packages.
- `curl` and `7zip` are installed automatically only when Kali image download is requested.
- The script safely adds the correct login user to the `libvirt` group, including when run with `sudo`.
