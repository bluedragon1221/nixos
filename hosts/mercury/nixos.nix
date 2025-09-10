{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./disks.nix
    ./battery.nix
    ./ai.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {facter.reportPath = ./facter.json;}

    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  fonts = {
    enableDefaultPackages = false;
    fontDir.enable = true;
    packages = with pkgs; [
      ibm-plex
      nerd-fonts.iosevka
    ];
  };

  services.speechd.enable = lib.mkForce false; # idk, im not disabled
  environment.defaultPackages = lib.mkForce []; # im not a noob

  networking.firewall.allowedUDPPorts = [445];
  networking.firewall.allowedTCPPorts = [8000];
  users.users.collin.packages = [pkgs.cifs-utils];

  system.stateVersion = "25.05";
}
