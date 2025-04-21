{pkgs, ...}: {
  catppuccin.dunst.enable = true;
  programs.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };
}
