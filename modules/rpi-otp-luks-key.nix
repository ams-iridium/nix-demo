{  ... }: 
{
  boot.initrd.systemd.enable = true;

  systemd.services.rpi-otp-luks-key = {
    description = "Create temporary initrd secret";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      install -d -m 0700 /run/secrets
      # replace this with rpi-otp-private-key logic
      echo 12345 > /run/secrets/luks.key
      chmod 0400 /run/secrets/luks.key
    '';
  };
}