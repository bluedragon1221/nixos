{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.gnome;
in
  lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;

    environment.gnome.excludePackages = with pkgs; [
      orca
      evince
      # file-roller
      geary
      # gnome-disk-utility
      seahorse
      # sushi
      # sysprof
      # gnome-shell-extensions
      adwaita-icon-theme
      # nixos-background-info
      gnome-backgrounds
      # gnome-bluetooth
      # gnome-color-manager
      # gnome-control-center
      # gnome-shell-extensions
      gnome-tour # GNOME Shell detects the .desktop file on first log-in.
      gnome-user-docs
      # glib # for gsettings program
      # gnome-menus
      # gtk3.out # for gtk-launch program
      # xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
      # xdg-user-dirs-gtk # Used to create the default bookmarks
      #
      baobab
      epiphany
      gnome-text-editor
      gnome-calculator
      gnome-calendar
      gnome-characters
      # gnome-clocks
      gnome-console
      gnome-contacts
      gnome-font-viewer
      gnome-logs
      gnome-maps
      gnome-music
      # gnome-system-monitor
      gnome-weather
      # loupe
      # nautilus
      gnome-connections
      simple-scan
      snapshot
      totem
      yelp
      gnome-software
    ];

    hjem.users."${config.collinux.user.name}".packages = with pkgs.gnomeExtensions; [blur-my-shell dash-to-dock] ++ [pkgs.wl-clipboard];

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/mutter" = {
              workspaces-only-on-primary = false;
            };
            "org/gnome/shell/app-switcher" = {
              current-workspace-only = true;
            };

            # Idle settings
            "org/gnome/desktop/session" = {
              idle-delay = lib.gvariant.mkInt16 0;
            };
            "org/gnome/settings-daemon/plugins/power" = {
              sleep-inactive-ac-type = "nothing";
            };

            # Theming, etc
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              enable-hot-corners = false;
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
              dash-max-icon-size = lib.gvariant.mkInt16 48;
              show-trash = false;
              show-mounts = false;
            };
          };
        }
      ];
    };
  }
