{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.glance;

  modularService = {
    lib,
    config,
    options,
    ...
  }: let
    cfg = config.glance;
  in {
    options.glance = {
      package = lib.mkOption {
        description = "the `glance` package";
        type = lib.types.package;
      };
      settings = lib.mkOption {
        description = "glance configuration file contents";
        type = (pkgs.formats.json {}).type;
      };
    };
    config =
      {
        configData."config.yml".text = builtins.toJSON (
          {
            server = {
              port = 8080;
              proxied = true;
              host = "127.0.0.1";
              assets-path = "/var/lib/glance";
            };
          }
          // cfg.settings
        );
        process.argv = [(lib.getExe cfg.package) "-config" config.configData."config.yml".path];
      }
      // lib.optionalAttrs (options ? systemd) {
        systemd.service = {
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            DynamicUser = true;
            StateDirectory = "glance";

            PrivateNetwork = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
          };
        };

        systemd.sockets."glance-proxy" = {
          wantedBy = ["sockets.target"];
          listenStreams = ["/run/glance/glance.sock"];
          socketConfig = {
            SocketMode = "0660";
            SocketGroup = "caddy";
          };
        };

        systemd.services."glance-proxy" = {
          requires = ["glance.service"];
          after = ["glance.service"];
          unitConfig.JoinsNamespaceOf = "glance.service";

          serviceConfig = {
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:8080";
            DynamicUser = true;
            PrivateNetwork = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
          };
        };
      };
  };
in {
  config = lib.mkIf cfg.enable {
    system.services."glance" = {
      imports = [modularService];
      glance = {
        package = pkgs.glance;
        settings = let
          servicesLinks = builtins.attrValues cfg.homelabServices;
          wrap = x: [x];
        in {
          branding.hide-footer = true;
          pages = wrap {
            name = "Dashboard";
            width = "slim";
            hide-desktop-navigation = true;
            center-vertically = true;
            columns = wrap {
              size = "full";
              widgets = [
                {
                  type = "search";
                  autofocus = true;
                  search-engine = "duckduckgo";
                  bangs = [
                    {
                      title = "GitHub";
                      shortcut = "gh";
                      url = "https://github.com/search?q={QUERY}&type=repositories";
                    }
                    {
                      title = "I'm Feeling Lucky";
                      shortcut = "!";
                      url = "https://www.google.com/search?q={QUERY}&btnI=&sourceid=navclient&gfns=1";
                    }
                    {
                      title = "YouTube Music";
                      shortcut = "ytm";
                      url = "https://music.youtube.com/search?q={QUERY}";
                    }
                    {
                      title = "Google AI Mode";
                      shortcut = "ai";
                      url = "https://www.google.com/search?udm=50&q={QUERY}";
                    }
                  ];
                }
                {
                  type = "server-stats";
                  servers = wrap {
                    type = "local";
                    name = "ganymede";
                    hide-mountpoints-by-default = true;
                    mountpoints = {
                      "/".hide = false;
                      "/media".hide = false;
                    };
                  };
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Services";
                  sites = servicesLinks;
                }
              ];
            };
          };
        };
      };
    };

    services.caddy.virtualHosts."home.ganymede".extraConfig = ''
      tls internal
      reverse_proxy unix///run/glance/glance.sock
    '';
  };
}
