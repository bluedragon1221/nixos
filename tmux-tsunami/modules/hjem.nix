{std, ...}: {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.tsunami;
in {
  imports = lib.filesystem.listFilesRecursive ./common;

  _module.args = {
    inherit std;
    tsunamiLib = {
      scriptPath = f: "~/.config/tmux/scripts/${f}.sh";
      filePath = f: "~/.config/tmux/files/${f}";
    };
  };

  files = lib.mkIf cfg.enable (lib.mkMerge [
    (
      cfg.scripts
      |> builtins.mapAttrs (name: value: {
        name = ".config/tmux/scripts/${name}.sh";
        value = {
          text = value;
          executable = true;
        };
      })
      |> lib.attrValues
      |> builtins.listToAttrs
    )
    (
      cfg.files
      |> builtins.mapAttrs (name: value: {
        name = ".config/tmux/files/${name}";
        value.text = value;
      })
      |> lib.attrValues
      |> builtins.listToAttrs
    )
    (
      cfg.confs
      |> builtins.mapAttrs (name: value: {
        name = ".config/tmux/conf.d/${name}.conf";
        value.text = value;
      })
      |> lib.attrValues
      |> builtins.listToAttrs
    )
    {
      ".config/tmux/tmux.conf".text = ''
        run-shell "find ~/.config/tmux/conf.d -print0 | xargs -0 -n1 tmux source-file"
      '';
    }
  ]);

  packages = lib.optional cfg.enable pkgs.tmux;
}
