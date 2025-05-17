{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;

  mkProgramOption' = name: extraOpts:
    {
      enable = mkEnableOption "whether to enable ${name}";
      theme = mkOption {
        type = types.enum ["catppuccin" "adwaita"];
        default = config.collinux.terminal.theme;
      };
    }
    // extraOpts;

  mkProgramOption = name: mkProgramOption name {};
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

        foot = mkProgramOption "the foot terminal emulator";
        blackbox.enable = mkEnableOption "the Black Box terminal emulator (for adwaita)";
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
        bat = mkProgramOption "bat";
        fzf = mkProgramOption "fzf";
        cmus = mkProgramOption "cmus";

        eza.enable = mkEnableOption "eza"; # unthemed

        starship = mkProgramOption' "starship prompt" {
          style = mkOption {
            type = types.enum ["default" "minimal" "powerline"];
            default = "minimal";
          };
        };
        helix = mkProgramOption' "helix text editor" {
          hardMode = mkOption {
            type = types.bool;
            description = "Disable arrow keys and mouse";
            default = false;
          };
        };
        tmux = mkProgramOption' "tmux terminal multiplexer" {
          # override
          enable = mkOption {
            type = types.bool;
            description = "whether to enable tmux terminal multiplexer";
            default = config.collinux.terminal.terminalEmulators.useTmux;
          };
        };

        nh.enable = mkEnableOption "nh"; # unthemed
      };
    };
  };
}
