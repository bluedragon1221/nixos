inputs': final: prev: let
  pkgs = prev;
in {
  inherit inputs';

  # util
  cfgWrapper = pkgs.callPackage ./util/cfgWrapper.nix {};
  subAll = pkgs.callPackage ./util/subAll.nix {};
  forceXdg = pkgs.callPackage ./util/forceXdg.nix {};

  # GUI Apps
  my-kitty = pkgs.callPackage ./my-kitty.nix {};
  my-foot = pkgs.callPackage ./my-foot.nix {};

  my-firefox = pkgs.callPackage ./my-firefox.nix {};

  # Music
  my-music = pkgs.callPackage ./my-music {};

  # Terminal
  my-fish = pkgs.callPackage ./my-fish {};
  my-helix = pkgs.callPackage ./my-helix.nix {};
  my-git = pkgs.callPackage ./my-git.nix {};
  my-tmux = pkgs.callPackage ./my-tmux {};

  hover-rs = pkgs.callPackage ./hover-rs.nix {};

  # Desktop
  my-fuzzel = pkgs.callPackage ./my-fuzzel.nix {};
  my-mako = pkgs.callPackage ./my-mako.nix {};
  my-waybar = pkgs.callPackage ./my-waybar {};

  my-hyprland = pkgs.callPackage ./my-hyprland.nix {};
}
