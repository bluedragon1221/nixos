{
  cfgWrapper,
  pkgs,
  hover-rs,
}: let
  my-git = pkgs.callPackage ./my-git.nix {};
  my-bat = pkgs.callPackage ./my-bat.nix {};
  my-starship = pkgs.callPackage ./my-starship.nix {};
  my-tmux = pkgs.callPackage ./my-tmux {};
  my-helix = pkgs.callPackage ./my-helix.nix {};
  my-fish = pkgs.callPackage ./my-fish.nix {
    extraApplications = [my-git my-bat my-helix my-starship my-tmux hover-rs my-starship];
  };
in
  pkgs.symlinkJoin {
    name = "my-term";
    paths = [my-fish my-tmux];
  }
