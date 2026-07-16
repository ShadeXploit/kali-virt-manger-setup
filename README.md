# kali-virt-manager-setup

Sets up virt-manager with everything needed to run Kali on Arch Linux.

I made this becuase I am sick of asking what I need to run kali linux smoothly LOL. 

## Run it

Copy this into your terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ShadeXploit/kali-virt-manger-setup/main/setup-virt-manager-arch.sh)
```

Or clone and run it manually:

```bash
git clone https://github.com/ShadeXploit/kali-virt-manger-setup.git
cd kali-virt-manger-setup
bash setup-virt-manager-arch.sh
```

Log out and back in after it finishes so the libvirt group takes effect.
