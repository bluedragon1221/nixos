{
  lib,
  config,
  tsunamiLib,
  ...
}: let
  inherit (tsunamiLib) scriptPath;
  inherit (lib.strings) escapeShellArg;
  cfg = config.tsunami.keys;
in {
  options = let
    tmuxKey = lib.types.strMatching "^((C|M|S)-)*(.|Enter|Escape|Tab|Up|Down|Left|Right)$";
    inherit (lib) mkOption;
  in {
    tsunami.keys = {
      leader = mkOption {
        type = with lib.types;
          listOf (submodule {
            options = {
              name = mkOption {type = str;};
              key = mkOption {type = tmuxKey;};
              exec = mkOption {type = str;};
            };
          });
      };

      global = mkOption {
        type = with lib.types;
          listOf (submodule {
            options = {
              key = mkOption {type = tmuxKey;};
              exec = mkOption {type = str;};
            };
          });
      };
    };
  };

  config = {
    tsunami.scripts = {
      "menu" = ''
        tmux display-menu \
          -x "#{window_width}" -y S \
          -b none \
          -s "bg=#313244,fg=#9399b2" \
          -S "bg=#313244" \
          -H "bg=#45475a fg=#b4befe" \
          "$@"
      '';

      "leader-menu" = let
        args = lib.concatStringsSep " " (builtins.map (f: "${escapeShellArg f.name} ${f.key} ${escapeShellArg f.exec}") cfg.leader);
      in ''
        ${scriptPath "menu"} ${args}
      '';
    };
    tsunami.keys.global = [
      {
        key = "C-x";
        exec = "run-shell ${scriptPath "leader-menu"}";
      }
    ];

    tsunami.confs."global-keys" = cfg.global |> builtins.map (f: "bind-key -n ${f.key} ${escapeShellArg f.exec}") |> lib.concatStringsSep "\n";
  };
}
