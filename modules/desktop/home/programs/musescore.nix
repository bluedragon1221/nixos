{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.collinux.desktop.programs.musescore;
in
  lib.mkIf cfg.enable {
    home.packages = [pkgs.musescore];

    # TODO: is there a way to declare a musescore configuration?
  }
