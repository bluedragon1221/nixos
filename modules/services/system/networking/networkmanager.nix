{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.networking;
in
  lib.mkIf (cfg.enable && cfg.networkmanager.enable) {
    networking = {
      nameservers = ["1.1.1.1" "1.0.0.1"];
      enableIPv6 = false;

      networkmanager.enable = true;
    };
  }
