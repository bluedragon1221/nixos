{
  pkgs,
  config,
  lib,
  tsunamiLib,
  std,
  ...
}: let
  inherit (tsunamiLib) scriptPath filePath;
  cfg = config.tsunami.sessionizer2;
in {
  options.tsunami.sessionizer2 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    tsunami.keys.leader = [
      {
        name = "New Session";
        key = "C-n";
        exec = "run-shell ${scriptPath "sessions-menu"}";
      }
    ];

    tsunami.files = {
      "broot_sessionizer2_launcher" = std.serde.toTOML {
        imports = ["~/.config/broot/conf.hjson"]; # inherit from user's config
        verbs = [
          {
            invocation = "tmux-window";
            external = ["tmux" "new-window" "-c" "#{?@default-path,#{@default-path},#{pane_current_path}}" "$EDITOR '{file}'"];
            key = "enter";
            apply_to = "file";
            leave_broot = false;
          }
          {
            invocation = "tmux-window";
            external = ["tmux" "new-window" "-c" "#{?@default-path,#{@default-path},#{pane_current_path}}" "$EDITOR '{file}'"];
            key = "enter";
            apply_to = "file";
            leave_broot = false;
          }
        ];
      };
    };
  };
}
