{ pkgs,  ... }: 
let
  secretsDirectory = "/run/secrets";
  luksKeyFile = "${secretsDirectory}/luks.key";
  luksKeySalt = "some-test-salt";
  
  rpiOtpKeyCommand = "echo '45678dddddd'";

  keygenScript = pkgs.writeShellScriptBin "rpi-gen-luks-key" ''
    if [ "$EUID" -ne 0 ]; then
      echo "Must be run as root"
      exit -1
    fi
    echo "$(${pkgs.raspberrypi-eeprom}/bin/rpi-otp-private-key) ${luksKeySalt}" | rev | cut -c 1-25 | rev
  '';

  getKeyService = extraConfig: {
    description = "Get the luks key from Raspberry Pi OTP.";
    serviceConfig = {
      Type = "oneshot";
    };
    # before = [ "cryptsetup.target" ];
    script = ''
      install -d -m 0700 '${secretsDirectory}'
      ${keygenScript} > '${luksKeyFile}'
      # echo "$(${keygenScript}/bin/rpi-gen-luks-key)" | sha256sum | tr -d ' -' > '${luksKeyFile}'
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