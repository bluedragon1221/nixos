{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  imports = [
    ./theme_adwaita.nix
    ./theme_catppuccin.nix
  ];

  options = {
    collinux.gtk.theme = mkOption {
      type = types.enum ["catppuccin" "adwaita"];
    };
  };

  config = {
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
  };
}
