# Adding a New User

This guide shows how to add a new user account to this repository and how that person can log in afterward.

It is written for someone who is still getting comfortable with Nix, so the goal here is to be explicit rather than clever.

## How User Accounts Work In This Repo

This project currently splits a user into two parts:

- A system user module in `modules/users/`
- A Home Manager configuration in `home/`

That split is important:

- The system user module creates the Linux account, sets group membership, and installs SSH keys.
- The Home Manager file controls the user's shell, Git config, packages, and other "inside the home directory" settings.

On top of that, the host file has to include both pieces.

For the existing `adam` user, the pieces are:

- [`modules/users/adam.nix`](/home/adam/nix-pseudo-design/modules/users/adam.nix)
- [`home/adam.nix`](/home/adam/nix-pseudo-design/home/adam.nix)
- [`hosts/ace/default.nix`](/home/adam/nix-pseudo-design/hosts/ace/default.nix)

## Example Goal

In this guide, we will pretend we are adding a user named `alice`.

You can replace `alice` with the real username everywhere.

## Step 1: Create The System User Module

Create a new file at `modules/users/alice.nix`.

Start with something like this:

```nix
{ ... }:
{
  users.users.alice = {
    isNormalUser = true;
    description = "Alice Example";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA... alice@laptop"
    ];
  };
}
```

What this does:

- `users.users.alice` creates the Linux account named `alice`
- `isNormalUser = true;` means this is a regular login user
- `extraGroups = [ "wheel" ];` gives sudo access on this host
- `openssh.authorizedKeys.keys` lets the user log in with SSH keys
  - You can copy/paste your *public* ssh key here to get remote ssh access.

If the user should not have sudo access, remove `"wheel"` from `extraGroups`.

## Step 2: Create The Home Manager File

Create a new file at `home/alice.nix`.

You can copy the shape of [`home/adam.nix`](/home/adam/nix-pseudo-design/home/adam.nix) and adjust it:

```nix
{ pkgs, ... }:
{
  home.username = "alice";
  home.homeDirectory = "/home/alice";

  home.stateVersion = "25.11";

  programs.bash.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.packages = with pkgs; [
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Alice Example";
    settings.user.email = "alice@example.com";
  };
}
```

What this does:

- Sets the username and home directory
- Enables Bash configuration through Home Manager
- Defines user-level packages and settings
- Configures Git for that specific user

`home.stateVersion` should usually match the version pattern already used in this repo unless you have a good reason to change it.

## Step 3: Register The User On The Host

Open [`hosts/ace/default.nix`](/home/adam/nix-pseudo-design/hosts/ace/default.nix).

There are two places to update.

First, add the new user module to the `modules = [ ... ]` list:

```nix
modules = [
  ../../modules/users/adam.nix
  ../../modules/users/alice.nix
  inputs.home-manager.nixosModules.default
  ...
];
```

Second, add the Home Manager entry:

```nix
home-manager.users.adam = import ../../home/adam.nix;
home-manager.users.alice = import ../../home/alice.nix;
```

Both are needed:

- Without the `modules/users/...` entry, the Linux account will not exist.
- Without the `home-manager.users...` entry, the user will exist but will not get the Home Manager configuration.

## Step 4: Rebuild The System

From the repository root, run:

```bash
sudo nixos-rebuild switch --flake .#ace
```

If you want to test first without making it the default boot configuration:

```bash
sudo nixos-rebuild test --flake .#ace
```

If the rebuild succeeds, the new account should now exist on the machine.

## Step 5: Access The New Account

There are two common ways to access the new user.

### Option A: SSH Login

If you added the user's public SSH key, they can log in over SSH:

```bash
ssh alice@ace.local
```

Or by IP address:

```bash
ssh alice@192.168.1.50
```

This host has Avahi enabled, so `.local` hostnames may work on your network.

### Option B: Switch Users Locally

If you already have shell access to the machine:

```bash
sudo su - alice
```

That opens a login shell as the new user.

## First Login Checklist

After the user logs in, it is worth checking:

- `whoami` prints the expected username
- `groups` shows the expected group membership
- `git config user.name` is set correctly
- `git config user.email` is set correctly
- the shell starts normally

## Common Mistakes

### The Rebuild Works, But The User Cannot Log In

Check the SSH key in `openssh.authorizedKeys.keys`.

Common problems:

- pasted the private key instead of the public key
- copied an incomplete key
- used the wrong username in the SSH command

### The User Exists, But Home Manager Settings Are Missing

This usually means the `home-manager.users.<name>` line was not added to the host file.

### The User Cannot Use `sudo`

Make sure the user has:

```nix
extraGroups = [ "wheel" ];
```

This repo currently allows passwordless sudo for members of `wheel` on `ace`.


## Quick Summary

To add a user in this repo, you usually need to do three things:

1. Add `modules/users/<name>.nix`
2. Add `home/<name>.nix`
3. Register both in [`hosts/ace/default.nix`](/home/adam/nix-pseudo-design/hosts/ace/default.nix)

Then rebuild with `sudo nixos-rebuild switch --flake .#ace`.
