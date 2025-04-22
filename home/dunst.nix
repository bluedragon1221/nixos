{pkgs, ...}: {
  catppuccin.dunst.enable = true;
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    settings = {
      global = {
        offset = "8x30";     
        origin = "top-right";
        transparency = 10;
        font = "Iosevka Nerd Font";
      };
    };
  };
}
