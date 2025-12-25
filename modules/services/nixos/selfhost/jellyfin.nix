{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.selfhost.jellyfin;
in
  lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.jellyfin = {
        enable = true;
      };
    }
    # (lib.mkIf (with config.collinux.services; networking.tailscale.enable && selfhost.caddy.enable) {
    #   services.caddy.virtualHosts."https://jellyfin.tail7cca06.ts.net".extraConfig = ''
    #     bind tailscale/jellyfin
    #     reverse_proxy localhost:${config.services.jellyfin.port}
    #   '';
    # })
  ])
