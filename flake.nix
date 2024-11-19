{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs = inputs: let
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [
        (import ./packages)
      ];
    };
  in {
    nixosConfigurations."collinux" = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs pkgs; };
      modules = [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
        ./system
        ./home
      ];
    };
  };
}

