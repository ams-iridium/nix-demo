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
      # rpi-otp-luks-key ${luksKeySalt} > '${luksKeyFile}'
      echo "hello i'm running a service"
      chmod 600 '${luksKeyFile}'
    '';
  } // extraConfig;
in
{
  # systemd.services.rpi-otp-luks-key = getKeyService {
  #  wantedBy = [ "multi-user.target" ];
  # };

  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.services.rpi-otp-luks-key-initrd = getKeyService {
    wantedBy = [ "initrd.target" ];
    wants = [ "rescue.target" ];
    before = [
      "initrd.target"
    #  "initrd-root-device.target"   # before disk discovery/mount
    #  "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = false;
  };
  boot.initrd.systemd.extraBin = {
    rpi-gen-luks-key = "${pkgs.rpi-otp-luks-key}/bin/rpi-gen-luks-key";
    rpi-otp-private-key = "${pkgs.rpi-otp-private-key}/bin/rpi-otp-private-key";
    vcgencmd = "${pkgs.libraspberrypi}/bin/vcgencmd";
    vcmailbox = "${pkgs.libraspberrypi}/bin/vcmailbox";
    awk = "${pkgs.gawk}/bin/awk";
    sed = "${pkgs.gnused}/bin/sed";
    grep = "${pkgs.gnugrep}/bin/grep";
    which = "${pkgs.which}/bin/which";
    xxd = "${pkgs.xxd}/bin/xxd";
  };

  # Allow an initrd rescue/emergency shell.
  # `true` means no password is required.
  # You can also set a hashed password here instead.
  boot.initrd.systemd.emergencyAccess = true;
}