{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.boot.plymouth;
in
  lib.mkIf cfg.enable {
    boot.plymouth = {
      enable = true;
      theme =
        if (cfg.theme == "catppuccin")
        then "catppuccin-macchiato" # for whatever reason catppuccin-mocha has errors
        else "nixos-bgrt";
      themePackages =
        if (cfg.theme == "catppuccin")
        then [pkgs.catppuccin-plymouth]
        else [pkgs.nixos-bgrt-plymouth];
    };
  }
