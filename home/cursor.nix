{pkgs, ...}: {
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 48;

    x11.enable = false;
    gtk.enable = false;
    hyprcursor.enable = true;
  };
}
