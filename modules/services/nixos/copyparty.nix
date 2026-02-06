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
        i = cfg.bind_host;
        p = [cfg.port];
        chpw = true;
        rproxy = "1";
        tls = false;
        usernames = true;

        e2dsa = true;
        e2ts = true;
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
                A = ["@admin"];
              };
            };
          }
        ]
        ++ lib.lists.flatten (cfg.users
          |> lib.attrsets.mapAttrsToList (k: v: [
            {
              "/${k}" = {
                path = "/media/${k}";
                access.A = [k];
              };
            }
            (lib.optionalAttrs v.hasPublicDir {
              "/public/${k}" = {
                path = "/media/${k}/public";
                access = {
                  r = "*";
                  A = [k];
                };
              };
            })
          ])));
    };
  };
}
