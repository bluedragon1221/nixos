{
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.terminal.shells;
in {
  imports = [
    ./programs/helix.nix
    ./programs/tmux.nix
    ./programs/fish.nix
    ./programs/starship.nix
    ./programs/lazygit.nix
    ./programs/cmus.nix
    ./programs/git.nix
  ];

  programs.command-not-found.enable = false; # broken without nix-channels

  users.users."${config.collinux.user.name}" = {
    shell = cfg.defaultShell;
    ignoreShellProgramCheck = true;
    packages = [pkgs.nh]; # Couldn't figure out where else to put this
  };
}
