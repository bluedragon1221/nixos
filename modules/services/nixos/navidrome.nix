{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.selfhost.navidrome;
in {
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Port = cfg.port;
        Address = cfg.bind_host;
        EnableInsightsCollector = false;
        MusicFolder = "/media/music";
      };
    };
  };
}
