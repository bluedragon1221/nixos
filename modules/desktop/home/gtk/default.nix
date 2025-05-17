{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.gtk;
in {
  imports =
    []
    ++ (lib.mkIf (cfg.theme == "catppuccin") [./catppuccin.nix])
    ++ (lib.mkIf (cfg.theme == "adwaita") [./adwaita.nix]);

  config = {
    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
  };
}
