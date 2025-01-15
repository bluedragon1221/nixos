{
  cfgWrapper,
  inputs',
  pkgs,
  my-kitty,
  my-firefox,
  my-mako,
  my-waybar,
  my-fuzzel,
  my-foot,
  my-music,
}: let
  my-waybar = pkgs.callPackge ./my-waybar {};
  my-fuzzel = pkgs.callPackage ./my-fuzzel.nix {};
  my-mako = pkgs.callPackge ./my-mako.nix {};
  my-hyprland = pkgs.callPackage ./my-hyprland.nix {};
in
  pkgs.symlinkJoin {
    name = "my-desktop";
    paths = [
      my-fuzzel
      my-hyprland
      my-mako
    ];
  }
