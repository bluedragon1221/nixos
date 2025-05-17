{pkgs, ...}: {
  catppuccin.waybar.enable = true;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings."mainBar" = import ./config.nix {inherit pkgs;};
    style = builtins.readFile ./style.scss;
  };
}
