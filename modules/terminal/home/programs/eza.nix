{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.eza;
in {
  programs.eza = {
    enable = true;
    extraOptions = ["-A" "-w" "80" "--group-directories-first"];
  };

  home.shellAliases = lib.mkIf cfg.alias {
    "ls" = "eza";
    "ll" = "ls -l";
    "tree" = "ls -T --ignore='.git*'";
    "lsg" = "ls -l --git --no-permissions --no-user --no-time --icons";
  };
}
