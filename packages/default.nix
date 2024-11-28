final: prev: let
  pkgs = prev;
in {
  cfgWrapper = pkgs.callPackage ./cfgWrapper.nix {};

  # CLI
  my-cava = pkgs.callPackage ./my-cava.nix {};
  my-cmus = pkgs.callPackage ./my-cmus.nix {};
  my-helix = pkgs.callPackage ./my-helix.nix {};
  my-git = pkgs.callPackage ./my-git.nix {};

  # Build from source
  hover-rs = pkgs.callPackage ./hover-rs.nix {};

  ## Shell
  my-starship = pkgs.callPackage ./my-starship.nix {};
  my-fish = pkgs.callPackage ./my-fish.nix {};

  # GUI
  my-kitty = pkgs.callPackage ./my-kitty.nix {};
  my-firefox = pkgs.callPackage ./my-firefox.nix {};

  my-fuzzel = pkgs.callPackage ./my-fuzzel.nix {};
  my-mako = pkgs.callPackage ./my-mako.nix {};

  my-hyprland = pkgs.callPackage ./my-hyprland.nix {};
}
