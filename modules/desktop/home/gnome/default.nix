{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.gnome;
in
  lib.mkIf cfg.enable {
    home.packages = with pkgs.gnomeExtensions; [
      blur-my-shell
      dash-to-dock
    ];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/mutter" = {
          workspaces-only-on-primary = false;
        };
        "org/gnome/shell/app-switcher" = {
          current-workspace-only = true;
        };

        # Idle settings
        "org/gnome/desktop/session" = {
          idle-delay = 0;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
        };

        # Keybindings
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>Return";
          command = "blackbox";
          name = "Terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };

        # Background
        "org/gnome/desktop/background" = rec {
          picture-uri = "file://${pkgs.gnome-backgrounds}/share/backgrounds/gnome/blobs-d.svg";
          picture-uri-dark = picture-uri;
        };

        # Extensions
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            blur-my-shell.extensionUuid
            dash-to-dock.extensionUuid
          ];
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          dash-max-icon-size = 48;
          show-trash = false;
          show-mounts = false;
        };
      };
    };
  }
