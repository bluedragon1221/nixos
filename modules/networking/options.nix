{
  lib,
  my-lib,
  ...
}: let
  inherit (my-lib.netTypes {inherit lib;}) ipAddr ipAddrCidr;
  inherit (lib) mkOption mkEnableOption;
in {
  options.collinux.system.network = {
    dns.areYouAServer = mkEnableOption "Set up unbound with the *.ganymede resolver and disable resolved stub";

    static = lib.mkOption {
      description = "Set a static IP address for this device on this network. Leave unset to use DHCP";
      type = lib.types.nullOr (lib.types.submodule {
        options = {
          ip = mkOption {
            description = "IP address";
            type = ipAddrCidr;
          };
          gateway = mkOption {
            description = "default gateway";
            type = ipAddr;
          };
        };
      });
      default = null;
    };

    wireless = {
      static = lib.mkOption {
        description = "Set a preconfigured SSID and PSK for the wireless config";
        type = lib.types.nullOr (lib.types.submodule {
          options = {
            ssid = mkOption {
              description = "SSID for this network";
              type = lib.types.str;
            };
            pskFile = mkOption {
              description = "Absolute path to a file containing the pre-shared key for this network in the form `psk:<wifi psk>`";
              type = lib.types.str;
              example = "/run/secrets.d/wifi-psk";
            };
          };
        });
        default = null;
      };
      dynamic = mkEnableOption "Enable dynamically joining wireless networks with iwd";
    };

    wireguard = {
      enable = mkEnableOption "Whether to enable Wireguard on this device";
      # peers = lib.types.listOf (lib.types.submodule {
      #   options = {
      #   };
      # });
    };
  };
}
