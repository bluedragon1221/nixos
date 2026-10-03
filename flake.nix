{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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

    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    geolite-db = {
      url = "file+https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download/GeoLite2-City.mmdb";
      flake = false;
    };

    shared-assets = {
      url = "git+ssh://git@ganymede/~/shared-assets";
      flake = false;
    };

    tmux-tsunami = {
      url = "git+https://git.collin.williamsfam.us.com/tmux-tsunami";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox modding stuff
    firefox-csshacks = {
      url = "github:MrOtherGuy/firefox-csshacks";
      flake = false;
    };
    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
    fx-autoconfig = {
      url = "github:MrOtherGuy/fx-autoconfig";
      flake = false;
    };
    uc-css-js = {
      url = "github:aminomancer/uc.css.js";
      flake = false;
    };
  };

  outputs = inputs: let
    inherit (import ./lib/nix-furnace/mkSystem.nix) mkNixosSystem genDocs;

    buildSystem = "x86_64-linux";
    buildPkgs = import inputs.nixpkgs {system = buildSystem;};
  in {
    nixosConfigurations."mercury" = mkNixosSystem {
      inherit inputs;
      hostname = "mercury";
      username = "collin";
    };
    nixosConfigurations."ganymede" = mkNixosSystem {
      inherit inputs;
      hostname = "ganymede";
      username = "collin";
    };

    packages.${buildSystem} = {
      "docs" = buildPkgs.callPackage genDocs {
        pkgs = buildPkgs;
        hostname = "mercury";
      };
      default = buildPkgs.callPackage ./pkgs/yo {
        pkgs = buildPkgs;
      };
    };
  };
}
