{
  cfgWrapper,
  pkgs,
}: let
  catppuccin-mako = builtins.fetchGit {
    url = "https://github.com/catppuccin/mako";
    rev = "92844f144e72f2dc8727879ec141ffdacf3ff6a1";
  };
in
  cfgWrapper {
    pkg = pkgs.mako;
    extraFlags = ["-c ${catppuccin-mako}/themes/catppuccin-late/catppuccin-latte-mauve"];
  }
