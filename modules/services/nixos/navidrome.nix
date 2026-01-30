{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.selfhost.navidrome;
in
  lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      inherit (cfg) user;
      settings = {
        Port = 4533;
        Address = "0.0.0.0";
        EnableInsightsCollector = false;
        MusicFolder = "/home/${cfg.user}/Music";
      };
    };
  }
