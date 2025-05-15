{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.hyprland;
in
  lib.mkIf (cfg.enable && cfg.components.waybar.enable) {
    catppuccin.waybar.enable = true;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings."mainBar" = import ./config.nix {inherit pkgs;};
      style = builtins.readFile ./style.scss;
    };
  }
