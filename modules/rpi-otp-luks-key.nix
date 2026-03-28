{ pkgs,  ... }: 
let
  secretsDirectory = "/run/secrets";
  luksKeyFile = "${secretsDirectory}/luks.key";
  luksKeySalt = "some-test-salt";
  
  rpiOtpKeyCommand = "echo '45678'";

  keygenScript = pkgs.writeShellScriptBin "rpi-gen-luks-key" ''
    echo '"$(${rpiOtpKeyCommand})"${luksKeySalt}' | sha256sum | tr -d ' -'
  '';

  getKeyService = extraConfig: {
    description = "Get the luks key from Raspberry Pi OTP.";
    serviceConfig = {
      Type = "oneshot";
    };
    # before = [ "cryptsetup.target" ];
    script = ''
      install -d -m 0700 '${secretsDirectory}'
      echo '"$(${rpiOtpKeyCommand})"${luksKeySalt}' | sha256sum | tr -d ' -' > '${luksKeyFile}'
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