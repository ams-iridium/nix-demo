{ ... }:
{
  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.services.save-initrd-logs = {
    wantedBy = [ "initrd.target" ];
    after = [
      "initrd-root-device.target"   # before disk discovery/mount
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /sysroot/var/log/initrd
      journalctl --no-pager -b _RUNTIME_SCOPE=initrd \
        > "/sysroot/var/log/initrd/$(date +%Y%m%d-%H%M%S)-initrd.log"
    '';
  };
}