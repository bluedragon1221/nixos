{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.selfhost.jellyfin;
in
  lib.mkIf cfg.enable {
    services.jellyfin.enable = true;
  }
