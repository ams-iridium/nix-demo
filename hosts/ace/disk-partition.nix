# USAGE in your configuration.nix.
# Update devices to match your hardware.
# {
#  imports = [ ./disko-config.nix ];
#  disko.devices.disk.main.device = "/dev/sda";
# }
{disko, ...}:
{
  imports = [
    disko.nixosModules.disko
  ];
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.services.my-test-secret = {
    description = "Create temporary initrd secret";

    wantedBy = [ "initrd.target" ];

    before = [
      "initrd-root-device.target"   # before disk discovery/mount
      "sysroot.mount"
    ];

    unitConfig.DefaultDependencies = false;

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      echo "12345" > /run/my-test-secret.txt
    '';
  };
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
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
            ESP = {
              # label = "ESP";

              type = "EF00";  # EFI System Partition (ESP)
              attributes = [
                2 # Legacy BIOS Bootable, for U-Boot to find extlinux config
              ];

              size = "1024M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "noatime"
                  "noauto"
                  "x-systemd.automount"
                  "x-systemd.idle-timeout=1min"
                  "umask=0077"
                ];
              };
            };
            rootfs = {
              size = "80G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}