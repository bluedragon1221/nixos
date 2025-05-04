{inputs, ...}: let
  mkUser = hostname: username: {
    isAdmin,
    password,
  }: {
    pkgs,
    lib,
    ...
  }: {
    home-manager = {
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit inputs;};
      users."${username}" = {
        imports = [
          inputs.catppuccin.homeModules.catppuccin
          ../modules/home.nix

          ../home/common.nix

          ./${hostname}/home.nix

          ./${hostname}/config.nix
        ];
      };
    };

    users.users."${username}" = {
      isNormalUser = true;
      # shell = pkgs.fish;
      # ignoreShellProgramCheck = true;
      description = username;
      extraGroups =
        ["networkmanager" "disks"]
        ++ (
          if isAdmin
          then ["wheel"]
          else []
        );
      hashedPassword = password;
    };
  };

  mkHost = hostname:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {networking.hostName = hostname;}

        ../modules/nixos.nix

        ../system/common.nix

        ./${hostname}/system.nix
        ./${hostname}/config.nix

        inputs.disko.nixosModules.disko
        ./${hostname}/disks.nix

        # Hardware-specific configuration
        inputs.nixos-facter-modules.nixosModules.facter
        {config.facter.reportPath = ./${hostname}/facter.json;}

        # Home-manager
        inputs.home-manager.nixosModules.home-manager
        (mkUser hostname "collin" {
          isAdmin = true;
          password = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
        })
      ];
    };
in {
  nixosConfigurations = {
    mercury = mkHost "mercury";
    jupiter = mkHost "jupiter";
  };
}
