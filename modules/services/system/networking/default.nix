{
  imports = [
    ./iwd.nix
    ./networkmanager.nix
  ];

  config = {
    services.resolved = {
      enable = true;
      domains = [
        "10.0.0.1"
        "10.0.0.10"
      ];
    };

    networking.resolvconf.enable = false;
  };
}
