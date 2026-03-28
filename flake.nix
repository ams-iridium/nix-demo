{
  description = "Nix infrastructure for pseudo.design";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-raspberrypi.url = "github:ams-tech/nixos-raspberrypi/rpi-otp-private-key";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, nixos-raspberrypi, disko, home-manager, ... }@inputs: 
  flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs {
        inherit system;
      };
      secretsDirectory = "/run/secrets";
      luksKeyFile = "${secretsDirectory}/luks.key";
      luksKeySalt = "some-test-salt";
    in 
    {
      packages.rpi-gen-luks-key = pkgs.writeShellScriptBin "rpi-gen-luks-key" ''
        install -d -m 0700 '${secretsDirectory}'
        '${pkgs.raspberrypi-eeprom}/bin/rpi-otp-private-key' > '${luksKeyFile}.tmp'
        echo '${luksKeySalt}' >> '${luksKeyFile}.tmp'
        cat '${luksKeyFile}.tmp' | sha256sum | tr -d ' -'
        rm -f '${luksKeyFile}.tmp'
      '';
    }
  ) //
  {
    nixosConfigurations = {
      # "'ace' is a Raspberry Pi 5 in Adam's house."
      ace = nixos-raspberrypi.lib.nixosSystemFull {
        specialArgs = inputs;
        modules = [
          ./hosts/ace
          ./modules/rpi-otp-luks-key.nix
        ];
      };

      rpi5-installer = nixos-raspberrypi.nixosConfigurations.rpi5-installer.extendModules {
        modules = [ ./modules/rpi-otp-luks-key.nix ];
      };
    };

    installerImages = let
      nixos = self.nixosConfigurations;
      mkImage = nixosConfig: nixosConfig.config.system.build.sdImage;
    in {
      rpi5 = mkImage nixos.rpi5-installer;
    };
  };
  
}
