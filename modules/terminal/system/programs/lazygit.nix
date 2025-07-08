{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.lazygit;

  settings = {
    git.paging.pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy";
    gui = {
      showRandomTip = false;
      commitLength.show = false;
    };
  };
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/lazygit/config.yml" = {
          generator = lib.generators.toYAML {};
          value = settings;
        };
      };

      packages = [pkgs.lazygit];
    };
  }
