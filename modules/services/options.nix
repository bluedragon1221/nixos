{lib, ...}: let
  inherit (lib) mkOption mkEnableOption types;

  basicService = {
    desc,
    default_port ? null,
  }: {
    enable = mkEnableOption desc;
    port = mkOption {
      type = lib.types.port;
      default = default_port;
    };
  };
in {
  options.collinux.services = {
    sshd = basicService {
      desc = "OpenSSH server";
      default_port = 22;
    };

    jta = basicService {desc = "personal project";};
    ganyupload = basicService {desc = "anonymous file uploads";};
    btopweb.enable = mkEnableOption "btop accessable in a browser tab";

    forgejo = basicService {desc = "Self-hosted git forge";};
    qbittorrent = basicService {desc = "webui for qBittorrent";};
    goaccess.enable = mkEnableOption "webserver stats from caddy logs";
    filebrowser.enable = mkEnableOption "dufs file browser";
    cgit.enable = mkEnableOption "cgit git webui";

    glance =
      (basicService {desc = "Glance homepage";})
      // {
        homelabServices = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
            options = {
              title = lib.mkOption {
                type = lib.types.str;
                default = config._module.args.name;
              };
              url = lib.mkOption {
                type = lib.types.str;
              };
              icon = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
            };
          }));
        };
      };

    minecraft = basicService {
      desc = "Minecraft bedrock server";
      default_port = 19132;
    };
    ngircd = basicService {
      desc = "ngircd IRC server";
      default_port = 6667;
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
