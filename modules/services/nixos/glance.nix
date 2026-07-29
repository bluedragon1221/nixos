{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.glance;

  pure = x: [x];

  servicesLinks = builtins.attrValues cfg.homelabServices;

  settings = {
    server = {
      inherit (cfg) port;
      proxied = true;
      host = "127.0.0.1";
      assets-path = "/var/lib/glance";
    };

    branding.hide-footer = true;
    pages = pure {
      name = "Dashboard";
      width = "slim";
      hide-desktop-navigation = true;
      center-vertically = true;
      columns = pure {
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
            servers = pure {
              type = "local";
              name = "Ganymede";
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

  settingsFile = (pkgs.formats.yaml {}).generate "config.yml" settings;
in {
  config = lib.mkIf cfg.enable {
    users.groups."glance" = {};
    users.users."glance" = {
      isSystemUser = true;
      group = "glance";

      home = "/var/lib/glance";
      createHome = true;
    };

    systemd.services."glance" = {
      restartIfChanged = true;
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "glance";
        Type = "simple";

        ReadWritePaths = "/var/lib/glance";
        WorkingDirectory = "/var/lib/glance";
        ExecStart = "${pkgs.glance}/bin/glance -config ${settingsFile}";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
      };
    };

    services.caddy.virtualHosts."home.ganymede".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:${toString cfg.port}
    '';
  };
}
