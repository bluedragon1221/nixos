{pkgs, ...}: {
  home.pointerCursor = {
    hyprcursor = {
      enable = true;
      size = 24;
    };
    gtk.enable = true;
    dotIcons.enable = false;

    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
  };

  catppuccin.gtk.enable = true; # this is okay because it's optionally imported
}
