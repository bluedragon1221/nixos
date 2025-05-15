{pkgs, ...}: {
  imports = [
    ./adwaita.nix
    ./catppuccin.nix
  ];

  config = {
    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
      };
    };
  };
}
