{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.lazygit;

  settings = {
    git.pagers = [{pager = "diff-so-fancy";}];
    gui = {
      showRandomTip = false;
      commitLength.show = false;
      showListFooter = false;
      showCommandLog = false;
      showPanelJumps = false;
      statusPanelView = "allBranchesLog";
    };
    update.method = "never";
    notARepository = "quit";

    quitOnTopLevelReturn = true;
    disableStartupPopups = true;
    promptToReturnFromSubprocess = false;

    theme.inactiveBorderColor = ["#313244"];
    theme.activeBorderColor = ["#89b4fa"];
  };
in
  lib.mkIf cfg.enable {
    files = {
      ".config/lazygit/config.yml" = {
        generator = lib.generators.toYAML {};
        value = settings;
      };
    };

    packages = [pkgs.lazygit pkgs.diff-so-fancy];
  }
