{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.glance;
in {
  config = lib.mkIf cfg.enable {
    system.services."glance" = {
      _module.args = {inherit pkgs;};
      imports = [./service_modules/glance.nix];

      caddy = {
        virtualHost = "home.ganymede";
        internal = true;
      };

      glance.settings = let
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

    services.unbound.settings.server.access-control = ["10.200.0.0/30 allow"];
  };
}
