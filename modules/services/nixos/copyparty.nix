{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.collinux.services.copyparty;
in {
  imports = [
    inputs.copyparty.nixosModules.default
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    users.groups."fileserver".members = [config.collinux.user.name];

    services.copyparty = {
      enable = true;

      user = "copyparty";
      group = "fileserver";

      settings = {
        i = cfg.listenAddr;
        p = [cfg.port];
        rproxy = "1";
        tls = false;

        usernames = true;
        no-robots = true;
        chmod-d = "775";

        e2dsa = true;
        hist = "/var/lib/copyparty/cache";

        # customization
        spinner = ",padding:0;border-radius:9em;border:.2em solid #444;border-top:.2em solid #fc0"; # no more tree
        ui-nolbar = true;
        ui-norepl = true;
      };

      accounts =
        cfg.users
        |> builtins.mapAttrs (k: v: {
          inherit (v) passwordFile;
        });

      groups.admin = cfg.users |> lib.attrsets.filterAttrs (k: v: v.isAdmin == true) |> builtins.attrNames;

      volumes = lib.mkMerge ([
          {
            "/" = {
              path = "/media/public";
              access = {
                r = "*";
                A = "@admin";
              };
            };

            "/library" = {
              path = "/media/library";
              access = {
                g = "*";
                r = "@acct";
                A = "@admin";
              };
              flags = {
                fk = 6;
                dk = 6;
                e2ts = true; # enable music indexing
              };
            };

            "/incoming" = {
              path = "/media/incoming";
              access = {
                wG = "*";
                A = "@admin";
              };
              flags = {
                fk = 6;
                dk = 6;
                lifetime = 21600; # files deleted after 6hrs
                nosub = true; # must upload to top-level folder
                maxb = "20g,21600"; # each IP can upload a max of 20GB every 6 hrs
              };
            };
          }
        ]
        ++ lib.lists.flatten (cfg.users
          |> lib.attrsets.mapAttrsToList (k: v: [
            {
              "/${k}" = {
                path = "/media/${k}";
                access.A = k;
              };
            }
            (lib.optionalAttrs v.hasPublicDir {
              "/public/${k}" = {
                path = "/media/${k}/public";
                access = {
                  r = "*";
                  A = k;
                };
              };
            })
          ])));
    };
  };
}
