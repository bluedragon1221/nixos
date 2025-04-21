{pkgs, ...}: {
  home.pointerCursor = {
    hyprcursor = {
      enable = true;
      size = 24;
    };
    gtk.enable = true;
    dotIcons.enable = false;

    package = pkgs.catppuccin-cursors.mochaDark;
    # name = "Catppuccin Mocha Dark";
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
  };

  catppuccin.gtk.enable = true;
  gtk = {
    enable = true;
  };
}
