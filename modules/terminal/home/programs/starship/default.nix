{
  config,
  lib,
  ...
}: {
  imports = [
    ./minimal.nix
    ./powerline.nix
  ];

  config = let
    cfg = config.collinux.terminal.programs.starship;
  in
    lib.mkIf cfg.enable {
      catppuccin.starship.enable = false; # relies on ifd
      programs.starship.enable = true;
    };
}
