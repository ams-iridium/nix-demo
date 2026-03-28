{ pkgs,  ... }: 
let
  secretsDirectory = "/run/secrets";
  luksKeyFile = "${secretsDirectory}/luks.key";
  luksKeySalt = "some-test-salt";
  
  rpiOtpKeyCommand = "echo '45678'";

  keygenScript = pkgs.writeShellScriptBin "rpi-gen-luks-key" ''
    install -d -m 0700 '${secretsDirectory}'
    '${pkgs.raspberrypi-eeprom}/bin/rpi-otp-private-key' > '${luksKeyFile}.tmp'
    echo '${luksKeySalt}' >> '${luksKeyFile}.tmp'
    cat '${luksKeyFile}.tmp' | sha256sum | tr -d ' -'
    rm -f '${luksKeyFile}.tmp'
  '';

  getKeyService = extraConfig: {
    description = "Get the luks key from Raspberry Pi OTP.";
    serviceConfig = {
      Type = "oneshot";
    };
    # before = [ "cryptsetup.target" ];
    script = ''
      install -d -m 0700 '${secretsDirectory}'
      ${rpiOtpKeyCommand} > '${luksKeyFile}.tmp'
      echo '${luksKeySalt}' >> '${luksKeyFile}.tmp'
      cat '${luksKeyFile}.tmp' | sha256sum | tr -d ' -'
    '';
  } // extraConfig;
in
{
  boot.initrd.systemd.enable = true;
  systemd.services.rpi-otp-luks-key = getKeyService {
    wantedBy = [ "multi-user.target" ];
  };
}