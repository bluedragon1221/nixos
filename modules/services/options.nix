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
    serviceName = mkOption {
      internal = true;
      type = lib.types.str;
      default = service_name;
    };
    port = mkOption {
      description = "The port on which ${service_name} will listen for incomming connections";
      type = lib.types.port;
      default = default_port;
    };
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

      forgejo = selfhostOptions {
        service_name = "forgejo";
        default_port = 8010;
      };

      navidrome = selfhostOptions {
        service_name = "navidrome";
        default_port = 8070;
      };

      copyparty =
        (selfhostOptions {
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

      ngircd = {
        enable = mkEnableOption "IRC Server";
        port = mkOption {
          type = lib.types.port;
          default = 6667;
        };
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
