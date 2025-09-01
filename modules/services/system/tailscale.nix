{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.collinux.services.networking.tailscale;
in
  lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
    environment.systemPackages = [pkgs.tailscale];
  }
