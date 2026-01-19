{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./minecraft.nix

    ./iwlwifi.nix
    ./caddy.nix
  ];

  services.tailscale.extraSetFlags = ["--advertise-exit-node"];

  networking.firewall.allowedUDPPorts = [51820];

  # backup usb teather configuration
  systemd.network.networks."80-usb-teather" = {
    name = "enp0s20f0u2";
    networkConfig.DHCP = "yes";
  };

  systemd.networks."12-wireguard" = {
    networkConfig.Address = lib.mkForce ["100.100.0.1/24"];
  };

  # i broke something and this fixes it
  environment.etc."systemd/resolved.conf.d/10-dns.conf".text = config.environment.etc."systemd/resolved.conf".text;
}
