{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;

  ip_addr = lib.types.strMatching "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$";
  ip_addr_cidr = lib.types.strMatching "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])/(3[0-2]|[12]?[0-9])$";
in {
  options = {
    collinux.services = {
      networking = {
        enable = mkEnableOption "wifi";

        iwd.enable = mkEnableOption "lightweight wifi daemon";
        networkmanager.enable = mkEnableOption "heavier wifi daemon";

        networkd = {
          enable = mkEnableOption "set static IP (systemd-networkd)";
          ssid = mkOption {type = lib.types.str;};
          pskFile = mkOption {type = lib.types.str;};

          static = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                ip = mkOption {type = ip_addr_cidr;};
                gateway = mkOption {type = ip_addr;};
              };
            });
            default = null;
          };
        };
        tailscale.enable = mkEnableOption "tailscale";
        sshd.enable = mkEnableOption "OpenSSH server";
      };
      audio = {
        enable = mkEnableOption "pipewire + wireplumber";
        pulse.enable = mkEnableOption "pipewire-pulse";
        # some config to make audio work with wine (TODO for jupiter)
      };
      bluetooth = {
        enable = mkEnableOption "bluetooth";
        blueman.enable = mkEnableOption "graphical bluetooth manager";
        bluetuith.enable = mkEnableOption "terminal bluetooth manager";
      };

      selfhost = let
        selfhostOptions = {
          service_name,
          default_port ? null,
          ...
        }: {
          enable = mkEnableOption "";
          bind_host = mkOption {
            type = ip_addr;
            default =
              if config.collinux.services.networking.tailscale.enable
              then "100.69.160.89"
              else "0.0.0.0";
          };
          port = mkOption {
            type = lib.types.port;
            default = default_port;
          };

          root_url = mkOption {
            type = lib.types.str;
            default =
              if config.collinux.services.networking.tailscale.enable
              then "https://${service_name}.tail7cca06.ts.net"
              else null;
          };
        };
      in {
        adguard = selfhostOptions {
          service_name = "adguard";
          default_port = 8001;
        };
        forgejo = selfhostOptions {
          service_name = "forgejo";
          default_port = 8010;
        };
        caddy = {
          enable = mkEnableOption "caddy https server";
          envFile = mkOption {
            type = lib.types.str;
          };
        };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = with config.collinux.services.networking; (iwd.enable && !networkmanager.enable && !networkd.enable) || (!iwd.enable && networkmanager.enable && !networkd.enable) || (!iwd.enable && !networkmanager.enable && networkd.enable);
        message = "only one networking method (iwd, networkmanager, static) can be active";
      }
    ];
  };
}
