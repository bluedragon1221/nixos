{inputs, ...}: let
  mkUser = userhost: let
    split = builtins.split "@" userhost; # ["collin" [] "collinux"]
    username = builtins.elemAt split 0;
    hostname = builtins.elemAt split 2;
  in {
    home-manager = {
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit inputs username hostname;};
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

  mkHost = hostname: let
    username = "collin";
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs username hostname;};
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
        (mkUser "${username}@${hostname}")
      ];
    };
in {
  nixosConfigurations =
    ["mercury" "jupiter"]
    |> builtins.map (x: {
      name = x;
      value = mkHost x;
    })
    |> builtins.listToAttrs;
}
