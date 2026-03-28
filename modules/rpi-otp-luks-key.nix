{ pkgs,  ... }: 
let
  secretsDirectory = "/run/secrets";
  luksKeyFile = "${secretsDirectory}/luks.key";
  luksKeySalt = "some-test-salt";

  getKeyService = extraConfig: {
    description = "Get the luks key from Raspberry Pi OTP.";
    serviceConfig = {
      Type = "oneshot";
    };
    # before = [ "cryptsetup.target" ];
    script = ''
      install -d -m 0700 ${secretsDirectory}
      # replace this with rpi-otp-private-key logic
      echo "$(${pkgs.raspberrypi-eeprom}/bin/rpi-otp-private-key)${luksKeySalt}" | sha256sum | tr -d ' -' > '${luksKeyFile}' 
      chmod 0400 ${luksKeyFile}
    '';
  } // extraConfig;
in
{
  boot.initrd.systemd.enable = true;
  systemd.services.rpi-otp-luks-key = getKeyService {
    wantedBy = [ "multi-user.target" ];
  };
  boot.initrd.systemd.services.rpi-otp-luks-key = getKeyService {
    wantedBy = [ "initrd.target" ];
  };
}