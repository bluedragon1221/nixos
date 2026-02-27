{
  # lib,
  config,
  ...
}: let
  cfg = config.collinux.system.network;
  dhcp_enabled = cfg.static == null;

  device =
    if (cfg.wireless == null)
    then "eth0"
    else "wl*";
in {
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      ignoredInterfaces = ["docker0"];
      anyInterface = true;
    };

    networks."11-default" =
      if dhcp_enabled
      then {
        name = device;
        networkConfig.DHCP = "yes";

        # never accept dhcp dns
        dhcpV4Config.UseDNS = "no";
        dhcpV6Config.UseDNS = "no";
      }
      else {
        name = device;
        networkConfig = {
          Address = cfg.static.ip;
          Gateway = cfg.static.gateway;
          DHCP = "no";
          # DNS is managed by systemd-resolved (not specified here)
        };
      };
  };
}
