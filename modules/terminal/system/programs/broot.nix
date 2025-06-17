{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;
  toml' = pkgs.formats.toml {};

  conf = toml'.generate "conf.toml" {
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
        ".config/broot/conf.toml".source = conf;
      };

      packages = [pkgs.broot];
    };
  }
