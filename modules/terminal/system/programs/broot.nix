{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;

  conf = {
    verbs = [
      {
        name = "open-code";
        key = "enter";
        execution = "$EDITOR +{line} {file}";
        working_dir = "{root}";
        leave_broot = true;
      }
    ];
  };
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/broot/conf.toml" = {
          generator = (pkgs.formats.toml {}).generate "conf.toml";
          value = conf;
        };

        ".config/fish/conf.d/broot.fish".text = lib.mkIf config.collinux.terminal.shells.fish.enable ''
          ${pkgs.broot}/bin/broot --print-shell-function fish | source
        '';
      };

      packages = [pkgs.broot];
    };
  }
