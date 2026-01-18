{lib, ...}: let
  inherit (lib) mkOption mkEnableOption;
in {
  options = {
    collinux.wireguard = {
      enable = mkEnableOption "wireguard";
      ip = mkOption {
        type = lib.types.str;
        description = "host's ip address on the wireguard network (with cidr)";
      };
      gateway = mkOption {
        type = lib.types.str;
        description = "host's gateway";
      };
      privateKeyFile = mkOption {
        type = lib.types.str;
        description = "path to local private key file";
        example = "/run/secretd.d/wireguard-key";
      };
      peers = mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            publicKey = mkOption {
              type = lib.types.str;
              description = "peer's public key";
            };
            ip = mkOption {
              type = lib.types.str;
              description = "peer's IP address";
            };
            endpoint = mkOption {
              type = lib.types.str;
              description = "peer's endpoint";
            };
          };
        });
      };
    };
  };
}
