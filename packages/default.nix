inputs': final: prev: let
  pkgs = prev;
in {
  inherit inputs';
  cfgWrapper = pkgs.callPackage ./cfgWrapper.nix {};
  substituteAll = import ./callPackage.nix {inherit pkgs;};
  forceXdg = pkgs.callPackage ./forceXdg.nix {};

  # GUI Apps
  my-kitty = pkgs.callPackage ./my-kitty.nix {};
  my-foot = pkgs.callPackage ./my-foot.nix {};

  my-firefox = pkgs.callPackage ./my-firefox.nix {};

  # Music
  my-music = pkgs.callPackage ./my-music/default.nix {};

  # Terminal
  my-fish = pkgs.callPackage ./my-fish {};
  my-starship = pkgs.callPackage ./my-starship.nix {};
  my-helix = pkgs.callPackage ./my-helix.nix {};
  my-git = pkgs.callPackage ./my-git.nix {};
  my-tmux = pkgs.callPackage ./my-tmux {};

  hover-rs = pkgs.callPackage ./hover-rs.nix {};

  # Desktop
  my-fuzzel = pkgs.callPackage ./my-fuzzel.nix {};
  my-mako = pkgs.callPackage ./my-mako.nix {};
  my-waybar = pkgs.callPackage ./my-waybar.nix {};

  my-hyprland = pkgs.callPackage ./my-hyprland.nix {};
}
