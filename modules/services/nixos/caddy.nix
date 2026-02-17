{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.caddy;
in
  lib.mkIf cfg.enable {
    services.caddy = {
      # just always install this. No harm in installing an extra plugin
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/tailscale/caddy-tailscale@v0.0.0-20251204171825-f070d146dd61"
        ];
        hash = "sha256-cK7C5ISsTwX0FMf891s/Vr22JvRqYEC8GkLfP1L1Mus=";
      };
      enable = true;
      environmentFile = cfg.envFile;
    };
    networking.firewall.allowedTCPPorts = [80 443];
    environment.systemPackages = with pkgs; [nss.tools]; # required for caddy https stuff
  }
