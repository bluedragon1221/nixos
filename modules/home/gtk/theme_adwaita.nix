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
}
