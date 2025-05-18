{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    (import ./lib/nix-furnace).mkFlake {
      inherit inputs;
      namespace = "collinux";
    };
}
