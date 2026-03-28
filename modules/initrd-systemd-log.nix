{ ... }:
{
  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.services.save-initrd-logs = {
    description = "DEBUG SERVICE TO PULL INITRD BOOT LOGS";
    wantedBy = [ "initrd.target" ];
    after = [
      "initrd-root-device.target"   # before disk discovery/mount
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /sysroot/home/adam/initrd
      journalctl --no-pager -b _RUNTIME_SCOPE=initrd \
        > "/sysroot/home/adam/initrd/$(date +%Y%m%d-%H%M%S)-initrd.log"
    '';
  };

    # Allow access to the initrd emergency shell.
  # For quick debugging:
  boot.initrd.systemd.emergencyAccess = true;

  # Pause in initrd just before handing off to the real rootfs.
  boot.kernelParams = [
    "rd.systemd.break=pre-switch-root"
  ];
}