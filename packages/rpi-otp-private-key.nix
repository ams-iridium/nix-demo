{
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rpi-otp-private-key";
  version = "2025.11.05-2712";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-eeprom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WByNvK115PbIJFMkZ4TYjU4QdNkyMrswAWcMlPIw2h4=";
  };

  nativeBuildInputs = [ makeWrapper ];


  installPhase = ''
    mkdir -p "$out/bin"
    cp tools/rpi-otp-private-key "$out/bin"
  '';

  fixupPhase = ''
    patchShebangs $out/bin
    for i in rpi-otp-private-key; do
      wrapProgram $out/bin/$i \
        --set FIRMWARE_ROOT "$out/lib/firmware/raspberrypi/bootloader" \
        ${lib.optionalString stdenvNoCC.hostPlatform.isAarch64 "--set VCMAILBOX ${libraspberrypi}/bin/vcmailbox"} \
        --prefix PATH : "${
          lib.makeBinPath (
            [
              binutils-unwrapped
              findutils
              flashrom
              gawk
              kmod
              which
              tinyxxd
              pciutils
              (placeholder "out")
            ]
            ++ lib.optionals stdenvNoCC.hostPlatform.isAarch64 [
              libraspberrypi
            ]
          )
        }"
    done
  '';

  meta = {
    description = "Installation scripts and binaries for the closed sourced Raspberry Pi 4 and 5 bootloader EEPROMs";
    homepage = "https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-4-boot-eeprom";
    license = with lib.licenses; [
      bsd3
      unfreeRedistributableFirmware
    ];
    # TODO: How do we approach this?
    # maintainers = with lib.maintainers; [
    #  das_j
    #  Luflosi
    # ];
    platforms = lib.platforms.linux;
  };
})