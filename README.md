# nix-pseudo-design

NixOS infrastructure for `pseudo.design`.

This repository is a small flake-based system configuration that currently manages a single host, `ace`, and layers in Home Manager for the `adam` user. The active host configuration targets a Raspberry Pi 5 and includes the machine-level NixOS setup, user account definition, and user-space configuration.

## What This Repo Contains

- A flake entrypoint in `flake.nix`
- One NixOS host definition: `ace`
- A user module that creates the `adam` account
- A Home Manager configuration for the `adam` user

## Repository Layout

```text
.
|- flake.nix
|- flake.lock
|- hosts/
|  `- ace/
|     `- default.nix
|- home/
|  `- adam.nix
`- modules/
   `- users/
      `- adam.nix
```

## Host Overview

The `ace` host configuration currently includes:

- Raspberry Pi 5 NixOS modules from `nixos-raspberrypi`
- Home Manager integration
- SSH access
- Avahi / mDNS support
- Smart card daemon (`pcscd`)
- `nix-command` and `flakes`
- A basic firewall with TCP ports `80` and `443` open
- `nix-ld` enabled for compatibility with some non-Nix binaries such as VS Code components

The filesystem layout for `ace` is defined directly in [`hosts/ace/default.nix`](/home/adam/nix-pseudo-design/hosts/ace/default.nix), so disk UUIDs and mount options are currently machine-specific.

## User Configuration

User management is split into two layers:

- [`modules/users/adam.nix`](/home/adam/nix-pseudo-design/modules/users/adam.nix) creates the system user, grants `wheel`, and installs SSH authorized keys.
- [`home/adam.nix`](/home/adam/nix-pseudo-design/home/adam.nix) manages user-space settings through Home Manager, including shell defaults and Git identity.

## Common Commands

Build the `ace` system configuration:

```bash
nix build .#nixosConfigurations.ace.config.system.build.toplevel
```

Test the configuration locally without making it the default boot target:

```bash
sudo nixos-rebuild test --flake .#ace
```

Apply the configuration to the current machine:

```bash
sudo nixos-rebuild switch --flake .#ace
```

Update flake inputs:

```bash
nix flake update
```

Inspect the flake outputs:

```bash
nix flake show
```

## Requirements

- Nix with flakes enabled
- A NixOS system for `nixos-rebuild` workflows
- Hardware settings that match the target machine, especially for:
  - Raspberry Pi boot configuration
  - Disk UUIDs in the filesystem definitions
  - SSH keys and any machine-specific networking choices

## Notes

- The flake currently exposes a single host: `ace`.
- Home Manager is integrated as a NixOS module rather than run separately.
- The repository is set up for direct, explicit configuration rather than a heavily abstracted module tree.

## Next Steps

Useful future improvements for this repo could include:

- Adding a `disko` layout if disk provisioning should be reproducible
- Introducing host-specific hardware or secrets modules
- Splitting reusable services into standalone modules as more hosts are added
