{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.gdm;
in
  lib.mkIf cfg.enable {
    services.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  }
