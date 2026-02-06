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
      };

      accounts = {
        collin = {
          passwordFile = config.collinux.secrets."collin-copyparty-password".path;
        };
      };
      volumes = let
        commonFlags = {
          scan = 60;
          chmod_f = "777";
          chmod_d = "777";
          ed2sa = true;
          dedup = true;
        };
      in {
        "/" = {
          path = "/media/public";
          access = {
            r = "*";
            A = ["collin"];
          };

          flags = commonFlags;
        };
        "/home/collin" = {
          path = "/media/collin";
          access = {
            r = "";
            A = ["collin"];
          };

          flags = commonFlags;
        };
      };
    };
  };
}
