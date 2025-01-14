{
  cfgWrapper,
  my-mako,
  my-kitty,
  pkgs,
}: let
  my-cmus = import ./my-cmus.nix {inherit cfgWrapper pkgs my-mako;};
  my-cava = import ./my-cava.nix {inherit cfgWrapper pkgs;};
  kitty-music = import ./kitty-music.nix {inherit pkgs my-kitty my-cava my-cmus;};
in
  pkgs.symlinkJoin {
    name = "my-music";
    paths = [
      my-cmus
      my-cava
      kitty-music
    ];
  }
