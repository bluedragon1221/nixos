{inputs, ...}:
let
  mkHost = name: inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      { networking.hostName = name; }

      ./${name}/system.nix
      ./${name}/home.nix

      # Hardware-specific configuration
      inputs.nixos-facter-modules.nixosModules.facter
      { config.facter.reportPath = ./${name}/facter.json; }

      # Home-manager
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          backupFileExtension = "bak";
          userGlobalPkgs = true;
          useUserPackages = true;
          users.collin = ./${name}/home.nix;
          extraSpecialArgs = {inherit inputs;};
        };
      }
    ];
  };
in {
  mercury = mkHost "mercury";
  # jupiter = mkHost "jupiter";
}
