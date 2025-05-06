{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.firefox;
in {
  imports = [
    ./profile.nix
    ./theme_adwaita.nix
    ./theme_catppuccin.nix
  ];

  config = lib.mkIf (cfg.enable) {
    programs.firefox.enable = true;
  };
}
