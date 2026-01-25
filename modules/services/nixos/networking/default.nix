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
}
