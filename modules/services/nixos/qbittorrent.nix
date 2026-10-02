{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.qbittorrent;
in {
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [49252];
      allowedUDPPorts = [49252];
    };

    services.qbittorrent = {
      enable = true;
      webuiPort = cfg.port;
      torrentingPort = 49252;
    };

    services.caddy.virtualHosts."bittorrent.ganymede".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:${toString cfg.port}
    '';

    collinux.services.glance.homelabServices."bittorrent" = {
      url = "https://bittorrent.ganymede";
      icon = "si:qbittorrent";
    };
  };
}
