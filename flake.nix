{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
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

    tsnsrv = {
      url = "github:boinkor-net/tsnsrv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    inherit (import ./lib/nix-furnace/mkSystem.nix) mkNixosSystem;
  in rec {
    nixosConfigurations."mercury" = mkNixosSystem {
      inherit inputs;
      hostname = "mercury";
      username = "collin";
    };
    nixosConfigurations."jupiter" = mkNixosSystem {
      inherit inputs;
      hostname = "jupiter";
      username = "collin";
    };
    nixosConfigurations."ganymede" = mkNixosSystem {
      inherit inputs;
      hostname = "ganymede";
      username = "collin";
    };

    deploy.nodes."ganymede" = {
      hostname = "ganymede";
      sshUser = "root";

      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations."ganymede";
      };
    };
  };
}
