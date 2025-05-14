{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.programs.firefox;
in {
  imports = [
    ./profile.nix
    ./adwaita.nix
    ./catppuccin.nix
  ];

  config = lib.mkIf (cfg.enable) {
    programs.firefox.enable = true;
  };
}
