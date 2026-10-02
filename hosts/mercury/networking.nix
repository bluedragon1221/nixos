{
  networking = {
    useDHCP = false;
    networkmanager.enable = false;
    dhcpcd.enable = false;
    resolvconf.enable = false;

    useNetworkd = true; # tells other services that we're using networkd (ex. tailscale)

    wireless.iwd = {
      enable = true;
      settings = {
        General.EnableNetworkConfiguration = false; # delegate to networkd
        Network.NameResolvingService = "systemd"; # delegate to systemd-resolved
      };
    };
  };

  systemd.network = {
    enable = true;
    networks."11-default" = {
      name = "wl*";
      networkConfig.DHCP = "yes";
    };
  };

  services.resolved.enable = true;
}
