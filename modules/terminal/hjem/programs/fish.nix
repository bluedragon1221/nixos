{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;
in
  lib.mkIf cfg.enable {
    files = {
      ".config/fish/conf.d/xdg.fish".text =
        # fish
        ''
          set -gx XDG_DATA_HOME "$HOME/.local/share"
          set -gx XDG_CONFIG_HOME "$HOME/.config"
          set -gx XDG_STATE_HOME "$HOME/.local/state"
          set -gx XDG_CACHE_HOME "$HOME/.cache"

          alias wget "wget --hsts-file=/dev/null"
          set -gx GOPATH "$XDG_DATA_HOME/go"
          set -gx GRADLE_USER_HOME "$XDG_DATA_HOME/gradle"
          set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
        '';

      ".config/fish/config.fish".text = ''
        set fish_greeting

        function fish_title
            echo fish (prompt_pwd)
        end

        direnv hook fish | source
        pay-respects fish --alias | source
      '';
    };

    packages = with pkgs; [
      fish
      ripgrep
      fd
      wget
      moreutils
      zip
      unzip
      btop
      jq
      direnv
      pay-respects
    ];
  }
