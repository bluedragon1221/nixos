{config, ...}: let
  cfg = config.collinux.terminal.shells;
in {
  imports = [
    ./programs/fzf.nix
    ./programs/bat.nix
    ./programs/lazygit.nix
    ./programs/eza.nix
    ./programs/starship.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/broot.nix
    ./programs/cmus.nix
    ./programs/helix.nix
    ./programs/fish.nix
  ];

  programs.command-not-found.enable = false; # broken without nix-channels

  users.users."${config.collinux.user.name}" = {
    shell = cfg.defaultShell;
    ignoreShellProgramCheck = true;
  };
}
