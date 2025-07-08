{
  pkgs,
  config,
  lib,
  my-lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  inherit (my-lib.options {inherit lib config;}) mkProgramOption' mkProgramOption;
in {
  options = {
    collinux.terminal = {
      theme = mkOption {
        type = types.enum ["catppuccin" "adwaita"];
        default = config.collinux.theme;
      };

      shells = {
        fish = mkProgramOption "fish shell";
        bash = mkProgramOption "bash shell";

        defaultShell = mkOption {
          type = types.package;
          description = "which shell is default";
          default = let
            cfg = config.collinux.terminal.shells;
          in
            if (cfg.fish.enable && !cfg.bash.enable)
            then pkgs.fish
            else if (!cfg.fish.enable && cfg.bash.enable)
            then pkgs.bash
            else null;
        };
      };

      programs = {
        lazygit.enable = mkEnableOption "lazygit";
        git = {
          enable = mkEnableOption "git";
          userName = mkOption {
            type = types.str;
            default = config.collinux.user.name;
          };
          userEmail = mkOption {
            type = types.str;
          };
        };

        tmux = mkProgramOption "tmux terminal multiplexer";

        helix = mkProgramOption' "helix text editor" {
          hardMode = mkOption {
            type = types.bool;
            description = "Disable arrow keys and mouse";
            default = false;
          };
        };

        cmus = mkProgramOption "cmus";
      };
    };
  };
}
