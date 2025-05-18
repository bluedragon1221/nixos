{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {facter.reportPath = ./facter.json;}

    ../../system/nix.nix
  ];

  systemd.network.wait-online.enable = false; # fix for weird wifi issue

  system.stateVersion = "25.05";
}
