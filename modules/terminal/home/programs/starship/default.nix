{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.starship;
in {
  # "theme" is catppuccin or adwaita
  # "style" is the layout of the components, reguardless of colors

  imports =
    []
    ++ (lib.mkIf (cfg.style == "minimal") [./minimal.nix])
    ++ (lib.mkIf (cfg.style == "powerline" && cfg.theme == "catppuccin") [./powerline.nix]);

  config = lib.mkIf cfg.enable {
    programs.starship.enable = true;
  };
}
