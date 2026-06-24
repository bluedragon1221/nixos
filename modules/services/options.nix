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
      port = mkOption {
        description = "Port to run on";
        type = lib.types.port;
        default = 22;
      };
      public = mkEnableOption "whether to make this service accessable over the internet";

      conf = {
        otp = mkEnableOption "Whether to require TOTP (Google Authenticator) 2fa codes to login";
        rootLogin = mkEnableOption "Whether to allow root login";
      };
    };
    minecraft = {
      enable = mkEnableOption "Minecraft bedrock server";
      port = mkOption {
        description = "port to run on";
        type = lib.types.port;
        default = 19132;
      };

      public = mkEnableOption "whether to make this service accessable over the internet";
    };
    ngircd = {
      enable = mkEnableOption "ngircd IRC server";
      port = mkOption {
        type = lib.types.port;
        default = 6667;
      };

      public = mkEnableOption "whether to make this service accessable over the internet";
    };

    jta = webserviceOptions {
      service_name = "jta";
    };
    ganyupload = webserviceOptions {
      service_name = "ganyupload";
    };
    forgejo = webserviceOptions {
      service_name = "forgejo";
    };
    btopweb = webserviceOptions {
      service_name = "btopweb";
    };
    goaccess = webserviceOptions {
      service_name = "goaccess";
    };
    cgit = webserviceOptions {
      service_name = "cgit";
      reverse_proxy = false;
    };
    qbittorrent = webserviceOptions {
      service_name = "qbittorrent";
    };

    caddy = {
      enable = mkEnableOption "caddy https server";
      envFile = mkOption {
        description = "Absolute path to file that contains environment files to run caddy with";
        type = types.str;
        example = "/run/secrets.d/caddy-env";
      };
    };
  };
}
