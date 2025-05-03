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
      };

      "org/gnome/desktop/background" = rec {
        picture-uri = "file://${pkgs.gnome-backgrounds}/share/backgrounds/gnome/blobs-d.svg";
        picture-uri-dark = picture-uri;
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
        ];
      };
    };
  };
}
