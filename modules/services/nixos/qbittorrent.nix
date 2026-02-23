{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.qbittorrent;
in {
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    users.users."qbittorrent".extraGroups = ["fileserver"]; # torrent files go to /media/library

    networking.firewall.allowedTCPPorts = [6882];
    networking.firewall.allowedUDPPorts = [6882];

    services.qbittorrent = {
      enable = true;
      webuiPort = cfg.port;
      torrentingPort = 6882;
    };
  };
}
