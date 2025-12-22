{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./iwlwifi.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
