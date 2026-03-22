{
  inputs,
  ...
}:
inputs.nixos-raspberrypi.lib.nixosSystem 
{
  specialArgs = inputs;
  modules = [
    ../../modules/users/adam.nix
    ({ pkgs, ...}: {

      imports = with inputs.nixos-raspberrypi.nixosModules; [
        raspberry-pi-5.base
        raspberry-pi-5.bluetooth
      ];
      boot.loader.raspberry-pi.bootloader = "kernel";
    })

    ({ ... }: {
      fileSystems = {
        "/boot/firmware" = {
          device = "/dev/disk/by-uuid/2175-794E";
          fsType = "vfat";
          options = [
            "noatime"
            "noauto"
            "x-systemd.automount"
            "x-systemd.idle-timeout=1min"
          ];
        };
        "/" = {
          device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
          fsType = "ext4";
          options = [ "noatime" ];
        };
      };
    })
  ];
}