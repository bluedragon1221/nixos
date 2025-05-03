{pkgs, ...}: {
  # Some networking articles:
  # https://nunq.net/posts/2023/captive
  # https://adityathebe.com/systemd-resolved-dns-over-tls

  services.resolved = {
    enable = true;
    domains = [
      "10.0.0.1"
      "10.0.0.10"
    ];
  };

  networking = {
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true; # use builtin dhcp client
          AddressRandomization = "once";
        };
        Network.NameResolvingService = "systemd"; # either systemd or resolvconf
      };
    };

    # Disable default networking stuff
    dhcpcd.enable = false;
    useDHCP = false;
    resolvconf.enable = false;
  };

  environment.systemPackages = [pkgs.openvpn];
}
