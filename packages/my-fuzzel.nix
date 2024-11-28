{
  cfgWrapper,
  pkgs,
}: let
  catppuccin-config = builtins.fetchGit {
    url = "https://github.com/catppuccin/fuzzel";
    rev = "0af0e26901b60ada4b20522df739f032797b07c3";
  };
  settings = pkgs.writeText "fuzzel.ini" ''
    include=${catppuccin-config}/themes/catppuccin-macchiato/blue.ini

    [main]
    dpi-aware=no
    prompt="  "

    font=Iosevka Nerd Font:size=13
    line-height=25
    lines=10
    width=30

    horizontal-pad=8
    vertical-pad=8

    [border]
    radius=0
    width=2
  '';
in
  cfgWrapper {
    pkg = pkgs.fuzzel;
    binName = "fuzzel";

    extraFlags = ["--config=${settings}" "--hide-before-typing"];
  }