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

  hover-rs = pkgs.callPackage ./hover-rs.nix {};

  my-mako = pkgs.callPackage ./my-mako.nix {};

  my-music = pkgs.callPackage ./my-music {};
  my-term = pkgs.callPackage ./my-term {};
  my-desktop = pkgs.callPackage ./my-desktop {};
}
