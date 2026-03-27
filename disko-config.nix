sudo nix run 'github:nix-community/disko/latest#disko-install' --   --flake .#ace --disk main /dev/nvme0n1

luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ ];
                settings = {
                  keyFile = "/run/luks.key";
                  allowDiscards = true;
                  preOpenCommands = ''
                    echo "12345" > "/run/luks.key"
                  '';
                  postOpenCommands = ''
                    rm "/run/luks.key"
                  '';
                };
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };

   lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          data = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/data";
            };
          };
        };
      };
    };