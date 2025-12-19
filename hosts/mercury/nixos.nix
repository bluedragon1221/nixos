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

  systemd.services.systemd-udev-settle.enable = false;
  networking.interfaces.wlp2s0.useDHCP = false;

  facter.reportPath = ./facter.json;

  environment.defaultPackages = lib.mkForce []; # im not a noob

  networking.firewall = {
    allowedUDPPorts = [445];
    allowedTCPPorts = [8000];
  };

  system.stateVersion = "25.05";
}
