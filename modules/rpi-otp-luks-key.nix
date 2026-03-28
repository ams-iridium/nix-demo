{  ... }: 
let
  secretsDirectory = "/run/secrcrets";
  luksKeyFile = "${secretsDirectory}/luks.key";
in
{
  systemd.services.rpi-otp-luks-key = {
    description = "Create temporary initrd secret";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      install -d -m 0700 ${secretsDirectory}
      # replace this with rpi-otp-private-key logic
      echo 12345 > ${luksKeyFile}
      chmod 0400 ${luksKeyFile}
    '';
  };
}