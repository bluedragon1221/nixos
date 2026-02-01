{
  lib,
  my-lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;
  inherit (my-lib.netTypes {inherit lib;}) ipAddr;

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
      type = ipAddr;
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
  options = {
    collinux.services = {
      sshd = {
        enable = mkEnableOption "OpenSSH server";

        portConfig = mkOption {
          description = "List of ssh bind hosts. see submodule options for details";
          type = lib.types.listOf (lib.types.submodule {
            options = {
              port = mkOption {
                description = "Port to run on";
                type = lib.types.port;
              };

              otp = mkEnableOption "Whether to require TOTP (Google Authenticator) 2fa codes for this port";
              rootLogin = mkEnableOption "Whether to allow root login for this port";
            };
          });
        };
      };

      adguard = selfhostOptions {
        service_name = "adguard";
        default_port = 8001;
      };

      forgejo =
        (selfhostOptions {
          service_name = "forgejo";
          default_port = 8010;
        })
        // {
          git_ssh_port = mkOption {
            type = lib.types.port;
            default = 2225;
          };
        };

      copyparty = selfhostOptions {
        service_name = "copyparty";
        default_port = 8099;
      };

      ngircd = {
        enable = mkEnableOption "IRC Server";
        port = mkOption {
          type = lib.types.port;
          default = 6667;
        };
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
}
