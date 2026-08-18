{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    ./disks.nix
    ./caddy.nix

    ./networking.nix
    ./wireguard.nix
  ];

  facter.reportPath = ./facter.json;

  services.fail2ban.enable = true;
}
