{
  pkgs,
  lib,
  config,
  ...
}: let
  isCatppuccin = config.collinux.theme == "catppuccin";
  useQtDesktop = config.collinux.desktop.wm.sway.enable || config.collinux.desktop.wm.niri.enable;
in
  lib.mkIf useQtDesktop {
    qt = {
      enable = true;
      platformTheme = "kde";
      style = "kvantum";
    };

    environment.systemPackages = lib.optionals isCatppuccin [
      pkgs.papirus-icon-theme
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

    systemd.user.extraConfig = lib.optionalString isCatppuccin ''
      DefaultEnvironment=KVANTUM_THEME=catppuccin-mocha-blue
      DefaultEnvironment=QT_STYLE_OVERRIDE=kvantum
      DefaultEnvironment=QT_QPA_PLATFORMTHEME=kde
      DefaultEnvironment=KDE_COLOR_SCHEME=CatppuccinMochaBlue
    '';

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

    hjem.users."${config.collinux.user.name}".xdg.config.files = lib.optionalAttrs isCatppuccin {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=catppuccin-mocha-blue
      '';

      "kdeglobals".text = ''
        [General]
        ColorScheme=CatppuccinMochaBlue

        [Icons]
        Theme=Papirus

        [KDE]
        widgetStyle=kvantum
      '';
    };
  }
