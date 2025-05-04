{
  pkgs,
  config,
  lib,
}: let
  cfg = config.collinux.shells;
in {
  users.users."${config.collinux.username}" = {
    shell = cfg.defaultShell;
    ignoreShellProgramCheck = true;
  };
}
