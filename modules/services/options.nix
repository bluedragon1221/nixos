{
  lib,
  my-lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  inherit (my-lib.netTypes {inherit lib;}) ipAddr;

  # A helper function to generate the submodule
  webserviceOptions = {
    service_name,
    default_port ? null,
    reverse_proxy ? true,
  }:
    {
      enable = mkEnableOption "${service_name} selfhosted service";
      listenAddr = mkOption {
        description = "The IP address on which ${service_name} will listen for incoming connections";
        type = ipAddr;
        default = "127.0.0.1";
      };
      privateUrl = mkOption {
        description = "Internal .local name for the service. Don't put the protocol (https://) in the string";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      publicUrl = mkOption {
        description = "Public website on which the service will be hosted. Don't put the protocol (https://) in the string";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    }
    // (
      if reverse_proxy
      then {
        reverseProxy = mkOption {
          internal = true;
          type = lib.types.bool;
          default = true;
        };
        port = mkOption {
          description = "The port on which ${service_name} will listen for incomming connections";
          type = lib.types.port;
          default = default_port;
        };
      }
      else {
        manualCaddyConfig = mkOption {
          description = "Configuration to describe this service in caddy, since reverse_proxy = false.";
          type = lib.types.str;
        };
      }
    );
in {
  options.collinux.services = {
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

            listenAddr = mkOption {
              description = "Address to listen on";
              type = lib.types.str;
              default = "127.0.0.1";
            };

            otp = mkEnableOption "Whether to require TOTP (Google Authenticator) 2fa codes for this port";
            rootLogin = mkEnableOption "Whether to allow root login for this port";
          };
        });
      };
    };

    forgejo = webserviceOptions {
      service_name = "forgejo";
      default_port = 8010;
    };

    goaccess = webserviceOptions {
      service_name = "goaccess";
      reverse_proxy = false;
    };

    cgit = webserviceOptions {
      service_name = "cgit";
      reverse_proxy = false;
    };

    polaris = webserviceOptions {
      service_name = "polaris";
      default_port = 8079;
    };

    qbittorrent = webserviceOptions {
      service_name = "qbittorrent";
      default_port = 8076;
    };

    copyparty =
      (webserviceOptions {
        service_name = "copyparty";
        default_port = 8099;
      })
      // {
        users = mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
            options = {
              name = mkOption {
                type = lib.types.str;
                default = config._module.args.name;
                internal = true;
              };
              isAdmin = mkEnableOption "whether this user is an admin";
              passwordFile = mkOption {
                description = "Absolute path to a file containing the password for this user";
                type = lib.types.str;
                example = "/run/secrets.d/copyparty-passwd";
              };
              hasPublicDir = mkEnableOption "give this user a world-readable directory at /public/<username>";
            };
          }));
        };
      };

    caddy = {
      enable = mkEnableOption "caddy https server";
      envFile = mkOption {
        type = types.str;
        example = "/run/secrets.d/caddy-env";
      };
    };
  };
}
