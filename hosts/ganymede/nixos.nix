{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./iwlwifi.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
