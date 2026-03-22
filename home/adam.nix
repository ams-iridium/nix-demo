# This file contains the "userspace" level configuration for the "adam" account.
# The "modules/users.nix" file actually creates those accounts on the target machine.
{ config, pkgs, ... }:
{
  home.username = "adam";
  home.homeDirectory = "/home/adam";

  home.stateVersion = "25.11";

  programs.bash.enable = true;

  programs.git = {
    enable = true;
    userName = "ams-tech";
    userEmail = "ams-tech@users.noreply.github.com";
  };

  programs.ssh.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.packages = with pkgs; [
    
  ];
}