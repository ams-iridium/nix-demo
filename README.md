# nix-pseudo-design

NixOS infrastructure for `pseudo.design`.

This repository is a small flake-based system configuration that currently manages a single host, `ace`, and layers in Home Manager for the `adam` user. The active host configuration targets a Raspberry Pi 5 and includes the machine-level NixOS setup, user account definition, and user-space configuration.

## Quickstart

**TODO: Link to document describing how to install nixos & set up qemu**

### Build the installer image

`nix build .#installerImages.rpi5 --refresh`

Note that this is significantly faster if you build it on an RPi5.  When running on Ubuntu, the system starts a QEMU instance and runs the build there.

This can be configured to use remote caches, but if you're bootstrapping infrastructure yourself on an x86 system, it'll take some time.

### Write the image to an SDCard

**TODO: Does this also work on USB?**

`zstdcat nixos-installer-rpi5-kernel.img.zst | sudo dd of=/dev/mmcblk0 bs=1M status=progress`


