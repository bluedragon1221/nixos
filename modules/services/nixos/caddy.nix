{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.caddy;
in
  lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];
    environment.systemPackages = with pkgs; [nss.tools]; # required for caddy https stuff
    services.caddy = {
      enable = true;
      environmentFile = cfg.envFile;
    };
  }
