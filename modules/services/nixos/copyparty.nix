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
        |> map (x: {
          inherit (x) passwordFile;
        });

      groups.admin = cfg.users |> lib.attrs.filterAttrs (k: v: v.isAdmin == true) |> builtins.attrNames;

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
          |> map (x: [
            {
              "/${x.name}" = {
                path = "/media/${x.name}";
                access.A = [x.name];
              };
            }
            (lib.optionalAttrs x.hasPublicDir {
              "/public/${x.name}" = {
                path = "/media/${x.name}/public";
                access = {
                  r = "*";
                  A = [x.name];
                };
              };
            })
          ])));
    };
  };
}
