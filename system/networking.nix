{pkgs, ...}: {
  networking = {
    nameservers = ["1.1.1.1" "1.0.0.1"];
    enableIPv6 = false;
    networkmanager.enable = true;
    resolvconf.enable = false;
  };

  services.resolved = {
    enable = true;
    domains = [
      "10.0.0.1"
      "10.0.0.10"
    ];
  };

  environment.systemPackages = [pkgs.openvpn];
}
