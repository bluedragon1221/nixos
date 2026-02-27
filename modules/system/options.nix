{
  lib,
  my-lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;
  inherit (my-lib.netTypes {inherit lib;}) ipAddr ipAddrCidr;
  inherit (my-lib.options {inherit lib config;}) mkThemeOption;
in {
  options.collinux.system = {
    boot = {
      systemd-boot.enable = mkOption {
        description = "Whether to use systemd-boot on this system";
        default = true;
      };
      timeout = mkOption {
        description = "bootloader timeout";
        type = lib.types.int;
        default = 0;
      };
      plymouth = {
        enable = mkEnableOption "plymouth bootsplash";
        theme = mkThemeOption "plymouth";
      };
      secureBoot.enable = mkEnableOption "lanzaboote";
    };

    network = {
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
        dynamic = lib.mkEnableOption "Enable dynamically joining wireless networks with iwd";
      };

      tailscale.enable = mkEnableOption "tailscale";
    };

    audio.enable = mkEnableOption "pipewire and wireplumber";
    bluetooth.enable = mkEnableOption "bluetooth";
  };

  config.assertions = [
    {
      assertion = let
        cfg = config.collinux.system.network.wireless;
      in
        !(cfg.static != null && cfg.dynamic);
      message = "Configure a static wireless connection or a dynamic one; not both.";
    }
  ];
}
