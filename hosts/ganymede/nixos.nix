{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./iwlwifi.nix
    ./caddy.nix
  ];

  services.tailscale.extraSetFlags = ["--advertise-exit-node"];

  # backup usb teather configuration
  systemd.network.networks."80-usb-teather" = {
    name = "enp0s20f0u2";
    networkConfig.DHCP = "yes";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
