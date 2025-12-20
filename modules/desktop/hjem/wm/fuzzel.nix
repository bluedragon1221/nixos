{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.desktop.wm.components.fuzzel;

  settings = {
    main = {
      prompt = "";
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
      width = 3;
    };

    colors = with config.collinux.palette; {
      background = "${base00}99";
      border = "ffffff00";
      input = base05;
      match = base13;
      placeholder = base03;
      text = base01;
      prompt = base01;

      selection = "${base01}5a";
      selection-match = base13;
      selection-text = base05;
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
