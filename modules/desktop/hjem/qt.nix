{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.qt;
  isCatppuccin = cfg.theme == "catppuccin";
in
  lib.mkIf cfg.enable {
    xdg.config.files =
      {
        "kdeglobals".text =
          ''
            [Icons]
            Theme=${cfg.iconTheme}
          ''
          + lib.optionalString isCatppuccin ''
            [General]
            ColorScheme=CatppuccinMochaBlue

            [KDE]
            widgetStyle=kvantum
          '';
      }
      // lib.optionalAttrs isCatppuccin {
        "Kvantum/kvantum.kvconfig".text = ''
          [General]
          theme=catppuccin-mocha-blue
        '';
      };
  }
