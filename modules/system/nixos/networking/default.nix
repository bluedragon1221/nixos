{
  imports = [
    ./iwd.nix
    ./networkmanager.nix
    ./networkd.nix
    ./resolved.nix
  ];

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };

  # disable all ipv6
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
  };
}
