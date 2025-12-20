{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    determinate = {
      url = "github:DeterminateSystems/nix-src/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-tsunami = {
      url = "github:bluedragon1221/tmux-tsunami";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-csshacks = {
      url = "github:MrOtherGuy/firefox-csshacks";
      flake = false;
    };
  };

  outputs = inputs: let
    inherit (import ./lib/nix-furnace/mkSystem.nix) mkNixosSystem mkSystemManagerSystem;
  in {
    nixosConfigurations."mercury" = mkNixosSystem {
      inherit inputs;
      hostname = "mercury";
      username = "collin";
      module_types = ["hjem" "nixos"];
    };
    nixosConfigurations."jupiter" = mkNixosSystem {
      inherit inputs;
      hostname = "jupiter";
      username = "collin";
      module_types = ["hjem" "nixos"];
    };
    nixosConfigurations."ganymede" = mkNixosSystem {
      inherit inputs;
      hostname = "ganymede";
      username = "collin";
      module_types = ["nixos" "hjem"];
    };
  };
}
