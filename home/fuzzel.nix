{
  catppuccin.fuzzel.enable = true;
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        prompt = "  ";
        dpi-aware = false;
        
        font = "Iosevka Nerd Font";
        line-height = 25;
        lines = 10;
        width = 30;

        horizontal-pad = 8;
        vertical-pad = 8;
      };
      border = {
        radius = 0;
        width = 2;
      };
    };
  };
}
