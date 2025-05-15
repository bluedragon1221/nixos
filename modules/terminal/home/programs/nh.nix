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
      clean.enable = true;
      flake = "/home/${config.collinux.user.name}/nixos";
    };
  }
