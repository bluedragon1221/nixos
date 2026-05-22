{
  lib,
  config,
  ...
}: let
  cfg = config.caddy;
in {
  options = {
    caddy = {
      globalConfig = lib.mkOption {
        description = "Configuration for top level stuff (ex. dns server api keys)";
        type = lib.types.lines;
        default = "";
      };
      tld = lib.mkOption {
        description = "Your publically accessable domain name";
        type = lib.types.str;
      };
      hostname = lib.mkOption {
        description = "Your computers hostname";
        type = lib.types.str;
      };
      virtualHosts = lib.mkOption {
        description = "Magically configure caddy for services";
        type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
          options = {
            serviceName = lib.mkOption {
              type = lib.types.str;
              default = config._module.args.name;
              internal = true;
            };
            access = lib.mkOption {
              type = lib.types.enum ["public" "private"];
              description = "public: accessable at {serviceName}.my.tld. private: accessable at {serviceName}.{hostname}";
            };
            logFile = lib.mkOption {
              type = lib.types.str;
              description = "what to name the log file under /var/log/caddy";
              default = "${config.serviceName}.log";
            };
            reverseProxy = lib.mkOption {
              type = with lib.types; nullOr str;
              description = "configure caddy to reverse-proxy this port or unix domain socket (ex. 127.0.0.1:8080 or unix//var/run/my_socket)";
              default = null;
            };
            virtualHostConfig = lib.mkOption {
              type = lib.types.lines;
              description = "manual config lines to add to the caddy config";
              default = "";
            };
          };
        }));
        default = {};
      };
    };
  };
  config = {
    configData."caddyfile".text =
      ''
        {
          ${cfg.globalConfig}
        }
      ''
      ++ (cfg.virtualHosts
        |> map (vhost_cfg: let
          target =
            if vhost_cfg.access == "public"
            then
              (
                if vhost_cfg.serviceName != "root"
                then "${vhost_cfg.serviceName}.${cfg.tld}"
                else cfg.tld
              )
            else
              (
                if vhost_cfg.serviceName != "root"
                then "${vhost_cfg.serviceName}.${cfg.hostName}"
                else cfg.hostname
              );
        in ''
          log {
            output file /var/log/caddy/${vhost_cfg.logFile}
          }

          ${target} {
            ${
            if vhost_cfg.access == "private"
            then "tls internal"
            else ""
          }
            ${
            if vhost_cfg.reverseProxy != null
            then "reverse_proxy ${vhost_cfg.reverseProxy}"
            else ""
          }
            ${vhost_cfg.virtualHostConfig}
          }
        '')
        |> builtins.concatStringsSep "\n\n");

    services."caddy".systemd.service = {
    };
  };
}
