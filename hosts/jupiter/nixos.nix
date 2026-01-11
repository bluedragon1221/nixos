{inputs, ...}: {
  imports = [
    ./disks.nix
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  facter.reportPath = ./facter.json;
}
