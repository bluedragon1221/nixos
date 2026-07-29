{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.system.network.wireless;
  enabled = cfg.static != null;
in
  lib.mkIf enabled {
    networking.wireless = {
      enable = true;
      networks.${cfg.static.ssid}.pskRaw = "ext:psk";
      secretsFile = cfg.static.pskFile;
    };
  }
