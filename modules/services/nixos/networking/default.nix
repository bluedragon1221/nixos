{
  imports = [
    ./iwd.nix
    ./networkmanager.nix
    ./static.nix
  ];

  config = {
    services.resolved = {
      enable = true;
      domains = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
    networking.resolvconf.enable = false;

    systemd.network.wait-online.enable = false;
  };
}
