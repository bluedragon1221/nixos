{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.terminal.programs.git;

  git_config = lib.mkMerge [
    {
      alias = {
        stage = "add";
        unstage = "restore --staged";
      };
      init.defaultBranch = "main";
      user = {
        email = cfg.userEmail;
        name = cfg.userName;
      };
    }
    (lib.mkIf cfg.installKey {
      # commit signing
      gpg.format = "ssh";
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3SjzIs3YI8PWJaNrAuaEeRcTcvIVHOKyCh2VwHTHEF";
      commit.gpgsign = "true";
    })
  ];
in {
  files = {
    ".config/git/config" = {
      generator = lib.generators.toGitINI;
      value = git_config;
    };
  };

  packages = [pkgs.git];
}
