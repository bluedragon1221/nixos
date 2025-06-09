{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.hyprland.components.waybar;
in
  lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings."mainBar" = import ./config.nix {inherit pkgs;};
      style = lib.mkIf (cfg.theme == "catppuccin") ''
        @import "${./catppuccin.scss}";

        ${builtins.readFile ./style.scss}
      '';
    };
  }
