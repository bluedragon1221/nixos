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
    services.copyparty = {
      enable = true;

      settings = {
        i = "0.0.0.0";
        p = [cfg.port];
        chpw = true;
        rproxy = "1";
        tls = false;
        usernames = true;

        e2dsa = true;
        e2ts = true;
      };

      accounts = {
        collin = {
          passwordFile = config.collinux.secrets."collin-copyparty-password".path;
        };
      };

      groups.admin = ["collin"];

      volumes = let
        commonFlags = {
          scan = 60;
          chmod_f = "777";
          chmod_d = "777";
        };
      in {
        "/" = {
          path = "/media/public";
          access = {
            r = "*";
            A = ["@admin"];
          };

          flags = commonFlags;
        };
        "/collin" = {
          path = "/media/collin";
          access.A = ["collin"];

          flags = commonFlags;
        };
        "/public/collin" = {
          path = "/media/collin/public";
          access = {
            r = "*a";
            A = ["collin"];
          };

          flags = commonFlags;
        };
      };
    };
  };
}
