{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.desktop.wm.components.fuzzel;

  settings = {
    main = {
      prompt = builtins.fromJSON ''"\u200B"''; # https://discourse.nixos.org/t/how-can-i-put-an-nonprintable-character-in-a-nix-expression/47750/7

      font = "Iosevka Nerd Font:size=9";
      use-bold = true;
      line-height = 16;
      lines = 10;
      width = 20;

      anchor = "bottom-right";

      horizontal-pad = 0;
      vertical-pad = 0;
    };
    border = {
      radius = 0;
      width = 3;
    };

    colors = with config.collinux.palette; let
      transparent = "#ffffff00";
    in {
      background = transparent;
      border = transparent;
      input = transparent;
      match = "#${base13}ff";
      placeholder = "#${base03}ff";
      text = "#${base04}ff";
      prompt = "#${base05}ff";

      selection = transparent;
      selection-match = "#${base13}ff";
      selection-text = "#${base05}ff";
    };
  };
in
  lib.mkIf cfg.enable {
    files.".config/fuzzel/fuzzel.ini" = {
      generator = lib.generators.toINI {};
      value = settings;
    };

    packages = [pkgs.fuzzel];
  }
