{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.lazygit;
in
  lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      settings = {
        gui.showRandomTip = false;
        gui.commitLength.show = false;
        git.paging.pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy";
      };
    };
  }
