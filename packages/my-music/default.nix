{
  cfgWrapper,
  my-mako,
  my-kitty,
  pkgs,
}: let
  a = {
    inherit cfgWrapper my-mako my-kitty;
    my-cmus = pkgs.callPackage ./my-cmus.nix {};
    my-cava = pkgs.callPackage ./my-cava.nix {};

    kitty-music = pkgs.callPackage ./kitty-music.nix {};
  };
in
  pkgs.symlinkJoin {
    name = "my-music";
    paths = [
      a.my-cmus
      a.my-cava
      a.kitty-music
    ];
  }
