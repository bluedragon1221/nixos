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

        ".config/fish/conf.d/broot.fish".text = lib.mkIf config.collinux.terminal.shells.fish.enable ''
          if status is-interactive
            ${pkgs.broot}/bin/broot --print-shell-function fish | source
          end
        '';
      };

      packages = [pkgs.broot];
    };
  }
