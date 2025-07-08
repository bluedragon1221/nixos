{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.nh;
in
  lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = "/home/collin/nixos";
      clean.enable = true;
    };
  }
