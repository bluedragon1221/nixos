{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.programs.ghostty;

  settings = with config.collinux.palette; ''
    font-family = Iosevka Nerd Font
    window-theme = ghostty

    background = ${base00}
    window-titlebar-background = ${base00}
    foreground = ${base05}
    window-titlebar-foreground = ${base05}

    selection-background = ${base02}
    selection-foreground = ${base00}

    palette = 0=${base00}
    palette = 1=${base08}
    palette = 2=${base11}
    palette = 3=${base10}
    palette = 4=${base13}
    palette = 5=${base14}
    palette = 6=${base12}
    palette = 7=${base05}
    palette = 8=${base03}
    palette = 9=${base08}
    palette = 10=${base11}
    palette = 11=${base10}
    palette = 12=${base13}
    palette = 13=${base14}
    palette = 14=${base12}
    palette = 15=${base07}
    palette = 16=${base09}
    palette = 17=${base15}
    palette = 18=${base01}
    palette = 19=${base02}
    palette = 20=${base04}
    palette = 21=${base06}
  '';
in
  lib.mkIf cfg.enable {
    files.".config/ghostty/config".text = settings;

    packages = [pkgs.ghostty];
  }
