{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.qt;
  isCatppuccin = cfg.theme == "catppuccin";
in
  lib.mkIf cfg.enable {
    qt = {
      enable = true;
      platformTheme = "kde";
      style = "kvantum";
    };

    environment.systemPackages =
      [
        pkgs.papirus-icon-theme
      ]
      ++ lib.optionals isCatppuccin [
        (pkgs.catppuccin-kde.override {
          flavour = ["mocha"];
          accents = ["blue"];
          winDecStyles = ["modern"];
        })
        (pkgs.catppuccin-kvantum.override {
          variant = "mocha";
          accent = "blue";
        })
      ];

    environment.pathsToLink = lib.optionals isCatppuccin [
      "/share/color-schemes"
      "/share/Kvantum"
    ];

    environment.sessionVariables = lib.optionalAttrs isCatppuccin {
      KVANTUM_THEME = "catppuccin-mocha-blue";
    };

    systemd.user.services.plasma-xdg-desktop-portal-kde = lib.mkIf isCatppuccin {
      overrideStrategy = "asDropin";
      serviceConfig.Environment = [
        "XDG_CURRENT_DESKTOP=KDE"
        "QT_QPA_PLATFORMTHEME=kde"
        "QT_STYLE_OVERRIDE=kvantum"
        "KVANTUM_THEME=catppuccin-mocha-blue"
        "KDE_COLOR_SCHEME=CatppuccinMochaBlue"
      ];
    };
  }
