{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.polaris;
in {
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    services.polaris = {
      enable = true;
      port = cfg.port;
      settings = {
        mount_dirs = [
          {
            name = "Ganymede Library";
            source = "/media/library/music";
          }
        ];
      };
    };
  };
}
