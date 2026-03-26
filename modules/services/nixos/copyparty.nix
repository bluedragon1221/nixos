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

    networking.firewall.allowedTCPPorts = lib.optional (cfg.listenAddr == "0.0.0.0") cfg.port;

    services.copyparty = {
      enable = true;

      user = "copyparty";
      group = "fileserver";

      settings = {
        i = cfg.listenAddr;
        p = [cfg.port];
        rproxy = "1";
        tls = false;

        name = "files@ganymede";
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

            "/public" = {
              path = "/var/empty";
              access.r = "*";
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
                dks = 6;
                e2ts = true; # enable music indexing
              };
            };
          }
        ]
        ++ lib.lists.flatten (cfg.users
          |> lib.attrsets.mapAttrsToList (k: v: [
            {
              "/${k}" = {
                path = "/media/${k}";
                access.rwd = k;
              };
            }
            (lib.optionalAttrs v.hasPublicDir {
              "/public/${k}" = {
                path = "/media/${k}/public";
                access.r = "*";
              };
            })
          ])));
    };
  };
}
