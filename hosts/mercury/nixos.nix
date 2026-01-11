{
  lib,
  inputs,
  ...
}: {
  imports = [
    ./disks.nix
    ./battery.nix
    ./ai.nix

    inputs.nixos-facter-modules.nixosModules.facter
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  services.syncthing = {
    enable = true;
    user = "collin";
    dataDir = "/home/collin/.local/syncthing";
  };

  facter.reportPath = ./facter.json;

  environment.defaultPackages = lib.mkForce []; # im not a noob

  networking.firewall = {
    allowedUDPPorts = [445];
    allowedTCPPorts = [8000];
  };
}
