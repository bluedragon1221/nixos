{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.hyprland;
in {
  imports =
    []
    ++ (lib.mkIf cfg.components.dunst.enable [./dunst.nix])
    ++ (lib.mkIf cfg.components.fuzzel.enable [./fuzzel.nix])
    ++ (lib.mkif cfg.enable [./hyprland.nix]);
}
