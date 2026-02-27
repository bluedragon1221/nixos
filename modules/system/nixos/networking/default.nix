{
  imports = [
    ./resolved.nix

    ./networkd.nix
    ./iwd.nix
    ./wpasupplicant.nix
  ];

  networking = {
    firewall = {
      enable = true;
      checkReversePath = "loose";
    };

    # Disable default networking stuff
    dhcpcd.enable = false;
    useDHCP = false;
    networkmanager.enable = false;
  };

  # disable all ipv6
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
  };
}
