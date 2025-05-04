{pkgs, ...}: {
  home.pointerCursor = {
    gtk.enable = true;
    dotIcons.enable = false;

    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
      };

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
        ];
      };
    };
  };
}
