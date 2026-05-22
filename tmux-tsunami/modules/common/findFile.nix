{
  pkgs,
  config,
  lib,
  tsunamiLib,
  std,
  ...
}: let
  inherit (tsunamiLib) scriptPath filePath;
  cfg = config.tsunami.findFile;
in {
  options = {
    tsunami.findFile = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    tsunami.keys.leader = [
      {
        name = "Find File";
        key = "C-f";
        exec = ''run-shell "${scriptPath "minibuffer"} -d '#{?@default-path,#{@default-path},#{pane_current_path}}' '${scriptPath "find-file"}'"'';
      }
    ];
    tsunami.scripts = {
      "minibuffer" = ''
        window_height="$(tmux display -p '#{window_height}')"
        tmux display-popup -EB \
          -w 100% -h 16 \
          -x 0 -y "$(($window_height + 1))" \
          "$@"
      '';

      "find-file" = ''${pkgs.broot}/bin/broot --conf ${filePath "broot_find_file.toml"}'';
    };

    tsunami.files."broot_find_file.toml" = std.serde.toTOML {
      imports = ["~/.config/broot/conf.hjson"];
      quit_on_last_cancel = true;
      verbs = [
        {
          invocation = "tmux-split";
          external = ["bash" "-c" ''${scriptPath "split"} -c "#{?@default-path,#{@default-path},#{pane_current_path}}" "$EDITOR '{file}'"''];
          key = "ctrl-s";
          apply_to = "file";
          leave_broot = true;
        }
        {
          invocation = "tmux-window";
          external = ["tmux" "new-window" "-c" "#{?@default-path,#{@default-path},#{pane_current_path}}" "$EDITOR '{file}'"];
          key = "ctrl-w";
          apply_to = "file";
          leave_broot = true;
        }
        {
          key = "enter";
          cmd = ":tmux-window";
        }
      ];
    };
  };
}
