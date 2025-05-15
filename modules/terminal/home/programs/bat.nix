{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.bat;
in
  lib.mkIf cfg.enable {
    catppuccin.bat.enable = false; # uses ifd
    programs.bat = {
      enable = true;
      config.theme = "base16"; # looks _good enough_, but a real catppuccin theme would be better
    };
    home.shellAliases."cat" = "bat";
  }
