{ pkgs,  ... }: 
let
  secretsDirectory = "/run/secrets";
  luksKeyFile = "${secretsDirectory}/luks.key";
  luksKeySalt = "some-test-salt";

  keygenScript = pkgs.writeShellScriptBin "rpi-gen-luks-key" ''
    # Exit on any error
    set -e
    # The '-c' flag ensures the key is not all 0s.
    ${pkgs.raspberrypi-eeprom}/bin/rpi-otp-private-key -c 
    RPI_OTP_SECRET=$(${pkgs.raspberrypi-eeprom}/bin/rpi-otp-private-key)
    echo "${luksKeySalt}$RPI_OTP_SECRET" | sha256sum | tr -d ' -'
  '';

  getKeyService = extraConfig: {
    description = "Get the luks key from Raspberry Pi OTP.";
    serviceConfig = {
      Type = "oneshot";
    };
    # before = [ "cryptsetup.target" ];
    script = ''
      install -d -m 0700 '${secretsDirectory}'
      ${keygenScript}/bin/rpi-gen-luks-key > '${luksKeyFile}'
      chmod 600 '${luksKeyFile}'
    '';
  } // extraConfig;
in
{
  boot.initrd.systemd.enable = true;
  systemd.services.rpi-otp-luks-key = getKeyService {
    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = [
    keygenScript
  ];
}