{pkgs, ...}: {
  imports = [
    ./theme_adwaita.nix
    ./theme_catppuccin.nix
  ];

  config = {
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
  };
}
