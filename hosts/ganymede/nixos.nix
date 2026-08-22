{
  inputs,
  hosts,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    ./disks.nix
    ./caddy.nix

    ./networking.nix
    ./wireguard.nix
  ];

  security.pki.certificates = [
    hosts.ganymede.caddy-root-ca
  ];

  facter.reportPath = ./facter.json;

  users.users."collin".extraGroups = ["fileserver"];

  services.fail2ban.enable = true;
}
