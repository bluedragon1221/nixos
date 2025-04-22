{pkgs, ...}: {
  catppuccin.dunst.enable = true;
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };
}
