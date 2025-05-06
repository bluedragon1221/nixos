{config, ...}: let
  cfg = config.collinux.terminal.shells;
in {
  programs.command-not-found.enable = false; # broken without nix-channels

  users.users."${config.collinux.user.name}" = {
    shell = cfg.defaultShell;
    ignoreShellProgramCheck = true;
  };
}
