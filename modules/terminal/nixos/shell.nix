{config, ...}: let
  cfg = config.collinux.terminal.shells;
in {
  users.users."${config.collinux.username}" = {
    shell = cfg.defaultShell;
    ignoreShellProgramCheck = true;
  };
}
