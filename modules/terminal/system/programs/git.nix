{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.terminal.programs.git;

  git_config = pkgs.writeText "config" ''
    [alias]
      stage = "add"
      unstage = "restore --staged"

    [init]
      defaultBranch = "main"

    [user]
      email = "${cfg.userEmail}"
      name = "${cfg.userName}"
  '';
in {
  hjem.users."${config.collinux.user.name}" = {
    files = {
      ".config/git/config".source = git_config;
    };

    packages = [pkgs.git];
  };
}
