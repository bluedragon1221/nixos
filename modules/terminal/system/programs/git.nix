{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.terminal.programs.git;

  git_config = {
    alias = {
      stage = "add";
      unstage = "restore --staged";
    };
    init.defaultBranch = "main";
    user = {
      email = cfg.userEmail;
      name = cfg.userName;
    };
  };
in {
  hjem.users."${config.collinux.user.name}" = {
    files = {
      ".config/git/config" = {
        generator = lib.generators.toGitINI;
        value = git_config;
      };
    };

    packages = [pkgs.git];
  };
}
