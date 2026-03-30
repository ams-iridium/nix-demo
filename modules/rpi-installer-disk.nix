{disko, pkgs, ...}:
{
  imports = [
    disko.nixosModules.disko
  ];
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              # label = "FIRMWARE";
              priority = 1;
              type = "0700";  # Microsoft basic data
              attributes = [
                0 # Required Partition
              ];
              size = "1024M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/firmware";
                mountOptions = [
                  "noatime"
                  "noauto"
                  "x-systemd.automount"
                  "x-systemd.idle-timeout=1min"
                ];
              };
            };
            swap = {
              priority = 2;
              size = "16G";
              content = {
                type = "swap";
              };
            };
            root = {
              # label = "ESP";
              type = "EF00";  # EFI System Partition (ESP)
              attributes = [
                2 # Legacy BIOS Bootable, for U-Boot to find extlinux config
              ];
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}