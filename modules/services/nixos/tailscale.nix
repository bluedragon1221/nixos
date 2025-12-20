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
      extraSetFlags = ["--ssh=true"];
    };
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
    environment.systemPackages = [pkgs.tailscale];
  }
