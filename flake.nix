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

    glide-browser = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-tsunami = {
      url = "github:bluedragon1221/tmux-tsunami";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yoshi-lua = {
      url = "github:bluedragon1221/yoshi";
      flake = false;
    };

    firefox-csshacks = {
      url = "github:MrOtherGuy/firefox-csshacks";
      flake = false;
    };
    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };

    nmd.url = "github:gvolpe/nmd";
  };

  outputs = inputs: let
    inherit (import ./lib/nix-furnace/mkSystem.nix) mkNixosSystem genDocs;

    system = "x86_64-linux";

    buildPkgs = import inputs.nixpkgs {inherit system;};

    deployPkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.deploy-rs.overlays.default
        (self: super: {
          deploy-rs = {
            inherit (buildPkgs) deploy-rs;
            lib = super.deploy-rs.lib;
          };
        })
      ];
    };
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

    packages."x86_64-linux".docs = buildPkgs.callPackage genDocs {
      inherit inputs;
      pkgs = buildPkgs;
      hostname = "mercury";
    };

    deploy.nodes."ganymede" = {
      hostname = "ganymede";
      sshUser = "root";

      profiles.system = {
        user = "root";
        path = deployPkgs.deploy-rs.lib.activate.nixos nixosConfigurations."ganymede";
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks deploy) inputs.deploy-rs.lib;
  };
}
