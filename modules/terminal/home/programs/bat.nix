{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.bat;
in
  lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config.theme = "base16";
    };
    home.shellAliases = {
      "cat" = "bat";
      "less" = "bat --plain --paging=always";
    };
  }
