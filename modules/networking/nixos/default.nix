{
  imports = [
    ./resolved.nix
    ./unbound.nix
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
    resolvconf.enable = false;
    dhcpcd.enable = false;
    useDHCP = false;
    networkmanager.enable = false;
  };
}
