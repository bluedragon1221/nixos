{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./settings_minimal.nix
    ./settings_powerline.nix
  ];

  config = let
    cfg = config.collinux.terminal.programs.starship;
  in
    lib.mkIf cfg.enable {
      catppuccin.starship.enable = false; # relies on ifd
      programs.starship.enable = true;
    };
}
