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
        # Themed
        starship = mkProgramOption "starship prompt";
        lazygit.enable = mkEnableOption "lazygit";

        cmus = mkProgramOption "cmus";
        nh.enable = mkEnableOption "nh nix helper";

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

        helix = mkProgramOption' "helix text editor" {
          hardMode = mkOption {
            type = types.bool;
            description = "Disable arrow keys and mouse";
            default = false;
          };
        };

        tmux = mkProgramOption "tmux terminal multiplexer";
        fzf = mkProgramOption "fzf fuzzy finder";
        bat = mkProgramOption "bat cat replacement";
        eza = mkProgramOption "eza ls replacement";
      };
    };
  };
}
