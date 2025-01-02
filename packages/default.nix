inputs': final: prev: let
  pkgs = prev;
in {
  inherit inputs';
  cfgWrapper = pkgs.callPackage ./cfgWrapper.nix {};
  forceXdg = pkgs.callPackage ./forceXdg.nix {};

  # GUI Apps
  my-kitty = pkgs.callPackage ./my-kitty.nix {};
  my-ghostty = pkgs.callPackage ./my-ghostty.nix {};
  my-firefox = pkgs.callPackage ./my-firefox.nix {};

  # Music
  my-cmus = pkgs.callPackage ./my-cmus.nix {};
  my-cava = pkgs.callPackage ./my-cava.nix {};
  kitty-music = pkgs.callPackage ./kitty-music.nix {};

  # Terminal
  my-fish = pkgs.callPackage ./my-fish.nix {};
  my-starship = pkgs.callPackage ./my-starship.nix {};
  my-helix = pkgs.callPackage ./my-helix.nix {};
  my-git = pkgs.callPackage ./my-git.nix {};

  hover-rs = pkgs.callPackage ./hover-rs.nix {};

  # Desktop
  my-fuzzel = pkgs.callPackage ./my-fuzzel.nix {};
  my-tofi = pkgs.callPackage ./my-tofi.nix {};
  my-mako = pkgs.callPackage ./my-mako.nix {};
  my-waybar = pkgs.callPackage ./my-waybar.nix {};

  my-hyprland = pkgs.callPackage ./my-hyprland.nix {};
}
