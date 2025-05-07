{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.user;
in {
  programs.git = {
    enable = true;
    userName = cfg.fullName;
    userEmail = cfg.email;
    aliases = {
      unstage = "restore --staged";
      stage = "add";
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
