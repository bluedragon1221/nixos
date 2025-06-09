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

  mkProgramOption = name: mkProgramOption' name {};
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
        nh.enable = mkEnableOption "nh";

        cmus = mkProgramOption "cmus";

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
      };
    };
  };
}
