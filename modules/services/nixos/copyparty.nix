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
        usernames = true;
      };

      accounts = {
        collin = {
          passwordFile = config.collinux.secrets."collin-copyparty-password".path;
        };
      };
      volumes = {
        "/" = {
          path = "/media";
          access = {
            r = "*";
            A = ["collin"];
          };

          flags = {
            scan = 60;
            chmod_f = 777;
          };
        };
      };
    };
  };
}
