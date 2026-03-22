{
  ...
}:
{
  imports = [
    # TODO: when root access is no longer required, move this to the top-level flake.nix file.
    ../../modules/users/adam.nix
    ./hardware-configuration.nix
  ];
  # This is the initial version of nixOS that was installed on this system.
  system.stateVersion = "25.11";
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
  networking.hostName = "ace";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  services.pcscd.enable = true;
  # Needed for vscode
  programs.nix-ld.enable = true;
}