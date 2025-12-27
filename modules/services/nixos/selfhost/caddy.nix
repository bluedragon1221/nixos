{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.selfhost.caddy;
in
  lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.caddy = {
        enable = true;
      };
      networking.firewall.allowedTCPPorts = [80 443];
      environment.systemPackages = with pkgs; [nss]; # required for caddy https stuff
    }
    (lib.mkIf config.collinux.services.networking.tailscale.enable {
      services.caddy = {
        package = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/tailscale/caddy-tailscale@v0.0.0-20251204171825-f070d146dd61"
          ];
          hash = "sha256-cK7C5ISsTwX0FMf891s/Vr22JvRqYEC8GkLfP1L1Mus=";
        };
        environmentFile = config.age.secrets."caddy-tailscale-authkey".path;
      };
    })
  ])
