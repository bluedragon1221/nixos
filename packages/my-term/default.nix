{
  cfgWrapper,
  pkgs,
  hover-rs,
}: let
  my-git = pkgs.callPackge ./my-git.nix {};
  my-bat = pkgs.callPackage ./my-bat.nix {};
  my-starship = pkgs.callPackage ./my-starship.nix {};
  my-tmux = pkgs.callPackge ./my-tmux {};
  my-helix = pkgs.callPackge ./my-helix.nix {};
  my-fish = pkgs.callPackge ./my-fish.nix {
    extraApplications = [my-git my-bat my-helix my-starship my-tmux hover-rs my-starship];
  };
in
  my-fish
