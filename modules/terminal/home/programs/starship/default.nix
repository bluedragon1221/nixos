{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.starship;
in {
  # "theme" is catppuccin or adwaita
  # "style" is the layout of the components, reguardless of colors

  imports = [
    ./minimal.nix
    ./powerline.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.starship.enable = true;
  };
}
