{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    collinux.terminal.programs.eza = {
      enable = lib.mkEnableOption "eza ls replacement";
      alias = lib.mkOption {
        type = lib.types.bool;
        description = "whether to override ls with an eza command";
      };
    };
  };

  config = let
    cfg = config.collinux.terminal.programs.eza;
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      {
        programs.eza = {
          enable = true;
          extraOptions = ["-A" "-w" "80" "--group-directories-first"];
        };
      }
      (lib.mkIf cfg.alias {
        home.shellAliases = {
          "ls" = "eza";
          "ll" = "ls -l";
          "tree" = "ls -T --ignore='.git*'";
          "lsg" = "ls -l --git --no-permissions --no-user --no-time --icons";
        };
      })
    ]);
}
