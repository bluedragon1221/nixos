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
          enable = mkEnableOption "use systemd-networkd";
          ssid = mkOption {
            description = "SSID for this network";
            type = lib.types.str;
          };
          pskFile = mkOption {
            description = "Absolute path to a file containing the pre-shared key for this network";
            type = lib.types.str;
            example = "/run/secrets.d/wifi-psk";
          };

          static = lib.mkOption {
            description = "Set a static IP address for this device on this network. Set to null to use DHCP";
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                ip = mkOption {
                  description = "IP address";
                  type = ip_addr_cidr;
                };
                gateway = mkOption {
                  description = "default gateway";
                  type = ip_addr;
                };
              };
            });
            default = null;
          };
        };

        tailscale.enable = mkEnableOption "tailscale";

        sshd = {
          enable = mkEnableOption "OpenSSH server";
          bind_host = mkOption {
            description = "The IP address on which OpenSSH will listen for incomming connections. The default, `0.0.0.0`, means 'all interfaces'";
            type = ip_addr;
            default = "0.0.0.0";
          };
        };
      };

      audio.enable = mkEnableOption "pipewire and wireplumber";

      bluetooth = {
        enable = mkEnableOption "bluetooth";
        blueman.enable = mkEnableOption "graphical bluetooth manager";
        bluetuith.enable = mkEnableOption "terminal bluetooth manager";
      };

      selfhost = let
        selfhostOptions = {
          service_name,
          default_port ? null,
        }: {
          enable = mkEnableOption "${service_name} selfhosted service";

          service_name = mkOption {
            type = lib.types.str;
            internal = true;
          };

          bind_host = mkOption {
            description = "The IP address on which ${service_name} will listen for incoming connections. The default, `0.0.0.0`, means 'all interfaces'";
            type = ip_addr;
            default = "0.0.0.0";
          };
          port = mkOption {
            description = "The port on which ${service_name} will listen for incomming connections";
            type = lib.types.port;
            default = default_port;
          };

          root_url = mkOption {
            description = "The final url that this service will be hosted on. Required for caddy, otherwise optional";
            type = lib.types.nullOr lib.types.str;
          };

          caddy = {
            enable = mkEnableOption "Automatically create caddy configurations for this service";
            bind_tailscale = mkEnableOption "Bind the service to ${service_name}.{tailnet}";
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

        headscale = selfhostOptions {
          service_name = "headscale";
          default_port = 8080;
        };

        caddy = {
          enable = mkEnableOption "caddy https server";
          envFile = mkOption {
            description = "Absolute path to file that contains environment variables for caddy operations";
            type = lib.types.str;
            example = "/run/secrets.d/caddy-env";
          };
        };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = with config.collinux.services.networking; (iwd.enable && !networkmanager.enable && !networkd.enable) || (!iwd.enable && networkmanager.enable && !networkd.enable) || (!iwd.enable && !networkmanager.enable && networkd.enable);
        message = "only one networking method (iwd, networkmanager, networkd) can be active";
      }
    ];
  };
}
