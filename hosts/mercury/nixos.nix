{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./disks.nix
    ./battery.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {facter.reportPath = ./facter.json;}

    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  environment.defaultPackages = lib.mkForce []; # im not a noob

  networking.firewall.allowedUDPPorts = [445];
  networking.firewall.allowedTCPPorts = [8000];
  users.users.collin.packages = [pkgs.cifs-utils];

  system.stateVersion = "25.05";
}
