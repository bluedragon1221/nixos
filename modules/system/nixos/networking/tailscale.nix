{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.collinux.system.network.tailscale;
in
  lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };

    networking.firewall = {
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };

    systemd.services."tailscaled" =
      if config.collinux.services.selfhost.headscale.enable
      then {
        # don't start tailscale until after headscale starts
        wants = lib.mkForce ["network.target" "headscale.target"];
        after = lib.mkForce ["network.target" "headscale.target"];
      }
      else {
        wants = lib.mkForce ["network.target"];
        after = lib.mkForce ["network.target"];
      };

    environment.systemPackages = [pkgs.tailscale];
  }
