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

    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };

    # don't start tailscale until after headscale starts
    systemd.services."tailscaled" = lib.mkIf config.collinux.services.selfhost.headscale.enable {
      wants = lib.mkForce ["network.target" "headscale.target"];
      after = lib.mkForce ["network.target" "headscale.target"];
    };

    environment.systemPackages = [pkgs.tailscale];
  }
