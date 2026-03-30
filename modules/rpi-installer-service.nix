{ config, pkgs, ... }:

let
  installScript = pkgs.writeShellScriptBin "pd-nix-install" ''
    clear
    BRANCH="${1:-latest}"
    nix run 'github:nix-community/disko/latest#disko-install' -- \
      --flake "github:pseudodesign/nix-pseudo-design/``${BRANCH}#ace" \
      --mode format \
      --disk main /dev/nvme0n1
  '';
in
{
  environment.systemPackages = [ installScript ];

  services.getty.autologinUser = "root";

  systemd.services.auoto-installer = {
    description = "Auto-Installer Application";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-user-sessions.service" "getty@tty1.service" ];
    serviceConfig = {
      User = "kiosk";
      TTYPath = "/dev/tty1";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "tty";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
      Restart = "always";
      ExecStart = "${installScript}/bin/pd-nix-install";
    };
  };
}