{inputs, ...}: let
  mkUser = hostname: username: {
    home-manager = {
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit inputs;};
      users."${username}" = {
        imports = [
          inputs.catppuccin.homeModules.catppuccin
          ../modules/home.nix

          ./${hostname}/home.nix
          ./${hostname}/config.nix
        ];
      };
    };
  };

  mkHost = hostname:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {networking.hostName = hostname;}

        ../modules/nixos.nix

        ./${hostname}/system.nix
        ./${hostname}/config.nix

        inputs.disko.nixosModules.disko
        ./${hostname}/disks.nix

        # Hardware-specific configuration
        inputs.nixos-facter-modules.nixosModules.facter
        {config.facter.reportPath = ./${hostname}/facter.json;}

        # Home-manager
        inputs.home-manager.nixosModules.home-manager
        (mkUser hostname "collin")
      ];
    };
in {
  nixosConfigurations = {
    mercury = mkHost "mercury";
    jupiter = mkHost "jupiter";
  };
}
