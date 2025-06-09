{
  config,
  pkgs,
  my-lib,
  ...
}: let
  cfg = config.collinux.terminal.shells;
in {
  imports = [
    ./programs/cmus.nix
    ./programs/fish.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/lazygit.nix
    ./programs/starship.nix
    ./programs/tmux.nix
  ];

  programs.command-not-found.enable = false; # broken without nix-channels

  users.users."${config.collinux.user.name}" = {
    shell = cfg.defaultShell;
    ignoreShellProgramCheck = true;
    packages = [pkgs.nh]; # Couldn't figure out where else to put this
  };
}
