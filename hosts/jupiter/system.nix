{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./minecraft.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {facter.reportPath = ./facter.json;}
  ];

  systemd.network.wait-online.enable = false; # fix for weird wifi issue

  system.stateVersion = "25.05";
}
