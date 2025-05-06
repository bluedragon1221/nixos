{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.hyprland;
in
  lib.mkIf cfg.enable {
    programs.uwsm.enable = cfg.useUwsm;
    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      withUWSM = cfg.useUwsm;
    };
  }
