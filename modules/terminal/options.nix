{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    collinux.terminal = {
      theme = mkOption {
        type = types.enum ["catppuccin" "adwaita"];
        default = config.collinux.theme;
      };

      font = {
        package = mkOption {
          type = types.package;
          default = pkgs.nerd-fonts.iosevka;
        };
        name = mkOption {
          type = types.str;
          default = "IosevkaNerdFont";
        };
      };

      terminalEmulators = {
        useTmux = mkOption {
          type = types.bool;
          description = "Make new tmux sessions for new foot windows to allow for splitting and tabs";
          default = false;
        };

        foot.enable = mkEnableOption "the foot terminal emulator";
        blackbox.enable = mkEnableOption "the Black Box terminal emulator (for adwaita)";
      };

      shells = {
        fish.enable = mkEnableOption "fish shell";
        bash.enable = mkEnableOption "bash shell";
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
        bat.enable = mkEnableOption "bat";
        eza.enable = mkEnableOption "eza";
        fzf.enable = mkEnableOption "fzf";

        nh.enable = mkEnableOption "nh";
        cmus.enable = mkEnableOption "cmus";

        starship = {
          enable = mkEnableOption "starship prompt";
          theme = mkOption {
            type = types.enum ["default" "minimal" "powerline"];
            default = "minimal";
          };
        };

        helix = {
          enable = mkEnableOption "helix text editor";
          hardMode = mkOption {
            type = types.bool;
            description = "Disable arrow keys and mouse";
            default = false;
          };
        };

        tmux = {
          enable = mkOption {
            type = types.bool;
            description = "Whether to enable the tmux terminal multiplexer";
            default = config.collinux.terminal.terminalEmulators.useTmux;
          };
        };
      };
    };
  };
}
