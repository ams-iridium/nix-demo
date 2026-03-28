{ pkgs,  ... }: 
let
  secretsDirectory = "/run/secrets";
  luksKeyFile = "${secretsDirectory}/luks.key";
  luksKeySalt = "some-test-salt";

  keygenScript = pkgs.writeShellScriptBin "rpi-gen-luks-key" ''
    # Exit on any error
    set -e
    # The '-c' flag ensures the key is not all 0s.
    otp_secret=$(${pkgs.raspberrypi-eeprom}/bin/rpi-otp-private-key -c)
    echo "${luksKeySalt}$otp_secret" | sha256sum | tr -d ' -'
  '';

  getKeyService = extraConfig: {
    description = "Get the luks key from Raspberry Pi OTP.";
    serviceConfig = {
      Type = "oneshot";
    };
    # before = [ "cryptsetup.target" ];
    script = ''
      set -e
      install -d -m 0700 '${secretsDirectory}'
      ${keygenScript}/bin/rpi-gen-luks-key > '${luksKeyFile}'
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