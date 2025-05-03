{inputs, ...}: let
  mkHost = name:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {networking.hostName = name;}

        ./common.nix

        ./${name}/system.nix

        inputs.disko.nixosModules.disko
        ./${name}/disks.nix

        # Hardware-specific configuration
        inputs.nixos-facter-modules.nixosModules.facter
        {config.facter.reportPath = ./${name}/facter.json;}

        # Home-manager
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            backupFileExtension = "bak";
            useGlobalPkgs = true;
            useUserPackages = true;
            users.collin = ./${name}/home.nix;
            extraSpecialArgs = {inherit inputs;};
          };
        }
      ];
    };
in {
  mercury = mkHost "mercury";
  jupiter = mkHost "jupiter";
}
