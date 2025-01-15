{
  cfgWrapper,
  inputs',
  pkgs,
  my-kitty,
  my-firefox,
  my-foot,
  my-music,
  my-mako,
}: let
  my-fuzzel = pkgs.callPackage ./my-fuzzel.nix {};
  my-waybar = pkgs.callPackage ./my-waybar {inherit my-fuzzel;};
  my-hyprland = pkgs.callPackage ./my-hyprland.nix {inherit my-fuzzel my-waybar;};
in
  my-hyprland
# pkgs.symlinkJoin {
#   name = "my-desktop";
#   paths = [
#     my-hyprland
#   ];
# }

