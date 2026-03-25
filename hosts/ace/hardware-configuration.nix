{ nixos-raspberrypi, disko, config, ... }: {
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-5.base
    raspberry-pi-5.page-size-16k
    raspberry-pi-5.display-vc4
    ./disk-partition.nix
  ];
  boot.loader.raspberry-pi.bootloader = "kernel";
  hardware.raspberry-pi.config = {
    all = { # [all] conditional filter, https://www.raspberrypi.com/documentation/computers/config_txt.html#conditional-filters

      # Base DTB parameters
      # https://github.com/raspberrypi/linux/blob/a1d3defcca200077e1e382fe049ca613d16efd2b/arch/arm/boot/dts/overlays/README#L132
      base-dt-params = {

        # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
        pciex1 = {
          enable = true;
          value = "on";
        };
        # PCIe Gen 3.0
        # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
        pciex1_gen = {
          enable = true;
          value = "3";
        };
      };
    };
  };
}