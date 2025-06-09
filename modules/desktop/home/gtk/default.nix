{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.gtk;
in {
  imports = [
    ./catppuccin.nix
    ./adwaita.nix
  ];

  config = {
    home.packages = [pkgs.dconf];

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
