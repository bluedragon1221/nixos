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
  '';
in
  cfgWrapper {
    pkg = pkgs.fuzzel;
    binName = "fuzzel";

    extraFlags = "--config=${settings}";
  }
