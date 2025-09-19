{inputs, ...}: {
  # imports = [
  #   inputs.disko.nixosModules.disko
  #   ./disks.nix
  # ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
