{
  pkgs,
  lib,
  config,
  ...
}: let
  useKdePortal = config.collinux.desktop.wm.sway.enable || config.collinux.desktop.wm.niri.enable;
in
  lib.mkIf useKdePortal {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      config = {
        common = {
          default = [
            "kde"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = ["kde"];
        };

        sway = {
          default = [
            "kde"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = ["kde"];
        };

        niri = {
          default = [
            "kde"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = ["kde"];
        };
      };

      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
    };

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "KDE";
      GTK_USE_PORTAL = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  }
