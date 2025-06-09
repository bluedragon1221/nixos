{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.hyprland;
in {
  imports = [
    ./hyprland
    ./dunst.nix
    ./fuzzel.nix
    ./waybar
  ];
}
