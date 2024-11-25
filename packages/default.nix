final: prev: let
  pkgs = prev;
in {
  cfgWrapper = pkgs.callPackage ./cfgWrapper.nix {};

  # CLI
  my-cava = pkgs.callPackage ./cava.nix {};
  my-cmus = pkgs.callPackage ./cmus.nix {};
  my-helix = pkgs.callPackage ./helix.nix {};
  my-git = pkgs.callPackage ./git.nix {};

  # Build from source
  lowfi = pkgs.callPackage ./lowfi.nix {};
  hover-rs = pkgs.callPackage ./hover-rs.nix {};
  bangscript = pkgs.callPackage ./bangscript.nix {};

  ## Shell
  my-starship = pkgs.callPackage ./starship.nix {};
  my-fish = pkgs.callPackage ./fish.nix {};

  # GUI
  my-kitty = pkgs.callPackage ./kitty.nix {};
  my-firefox = pkgs.callPackage ./firefox.nix {};

  my-fuzzel = pkgs.callPackage ./fuzzel.nix {};
  my-mako = pkgs.callPackage ./mako.nix {};
}
