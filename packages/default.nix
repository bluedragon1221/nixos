final: prev: let
  pkgs = prev;
in {
  cfgWrapper = pkgs.callPackage ./cfgWrapper.nix {};

  # GUI Apps
  my-kitty = pkgs.callPackage ./my-kitty.nix {};
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
  my-mako = pkgs.callPackage ./my-mako.nix {};
  my-waybar = pkgs.callPackage ./my-waybar.nix {};

  my-hyprland = pkgs.callPackage ./my-hyprland.nix {};
}
