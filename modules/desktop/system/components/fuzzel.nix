{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.desktop.components.fuzzel;
  ini' = pkgs.formats.ini {};

  settings = ini'.generate "fuzzel.ini" {
    main = {
      prompt = "    ";
      dpi-aware = false;

      font = "Iosevka Nerd Font";
      line-height = 25;
      lines = 10;
      width = 30;

      horizontal-pad = 8;
      vertical-pad = 8;
    };
    border = {
      radius = 0;
      width = 2;
    };

    colors = {
      background = "1e1e2edd";
      text = "cdd6f4ff";
      prompt = "bac2deff";
      placeholder = "7f849cff";
      input = "cdd6f4ff";
      match = "89b4faff";
      selection = "585b70ff";
      selection-text = "cdd6f4ff";
      selection-match = "89b4faff";
      counter = "7f849cff";
      border = "89b4faff";
    };
  };
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/fuzzel/fuzzel.ini".source = settings;
      };
      packages = [pkgs.fuzzel];
    };
  }
