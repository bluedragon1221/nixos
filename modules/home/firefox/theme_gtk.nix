{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.firefox;
in
  lib.mkIf (cfg.theme == "gtk") {
    # TODO add desktop's firefox customization
  }
