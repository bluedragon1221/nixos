{
  pkgs,
  lib,
  config,
  ...
}: let
  wmCfg = config.collinux.desktop.wm;
  useGtkPortal = wmCfg.gtkDesktopPortal.enable;
  useKdePortal = wmCfg.kdeDesktopPortal.enable;
  usePortal = useGtkPortal || useKdePortal;
  defaultBackends =
    if useKdePortal
    then [
      "kde"
      "gtk"
    ]
    else [
      "gtk"
      "kde"
    ];
  fileChooserBackend = if useKdePortal then ["kde"] else ["gtk"];
in
  lib.mkIf usePortal {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      config = {
        common = {
          default = defaultBackends;
          "org.freedesktop.impl.portal.FileChooser" = fileChooserBackend;
        };

        sway = {
          default = defaultBackends;
          "org.freedesktop.impl.portal.FileChooser" = fileChooserBackend;
        };

        niri = {
          default = defaultBackends;
          "org.freedesktop.impl.portal.FileChooser" = fileChooserBackend;
        };
      };

      extraPortals =
        lib.optionals useKdePortal [pkgs.kdePackages.xdg-desktop-portal-kde]
        ++ lib.optionals useGtkPortal [pkgs.xdg-desktop-portal-gtk];
    };

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = if useKdePortal then "KDE" else "sway";
      GTK_USE_PORTAL = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  }
