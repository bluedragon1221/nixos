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
        invocation = "edit";
        key = "enter";
        execution = "${pkgs.helix}/bin/hx {file}";
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
