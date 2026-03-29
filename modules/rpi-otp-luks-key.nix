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
      install -d -m 0700 '${secretsDirectory}'
      ${pkgs.rpi-otp-luks-key}/bin/rpi-otp-luks-key ${luksKeySalt} > '${luksKeyFile}'
      chmod 600 '${luksKeyFile}'
    '';
  } // extraConfig;
in
{
  # boot.initrd.systemd.enable = true;
  systemd.services.rpi-otp-luks-key = getKeyService {
    wantedBy = [ "multi-user.target" ];
  };


#  boot.initrd.systemd.services.rpi-otp-luks-key-initrd = getKeyService {
#    wantedBy = [ "initrd.target" ];
#    before = [
#      "initrd-root-device.target"   # before disk discovery/mount
#      "sysroot.mount"
#    ];
#    unitConfig.DefaultDependencies = false;
#  };
#  boot.initrd.systemd.extraBin = {
#    rpi-gen-luks-key = "${keygenScript}/bin/rpi-gen-luks-key";
#    rpi-otp-private-key = "${pkgs.rpi-otp-private-key}/bin/rpi-otp-private-key";
#    vcgencmd = "${pkgs.libraspberrypi}/bin/vcgencmd";
#    vcmailbox = "${pkgs.libraspberrypi}/bin/vcmailbox";
#  };
}