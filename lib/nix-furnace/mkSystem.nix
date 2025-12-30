let
  my-lib = import ../lib.nix;
  inherit (my-lib.globimport) getSubdirs lazyImport;

  listModules = getSubdirs ../../modules;

  mkNixosSystem = {
    inputs,
    hostname,
    username,
    module_types,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs my-lib hostname;};
      modules = [
        {networking.hostName = hostname;}

        ../../hosts/${hostname}/config.nix

        # Nixos-sided modules
        {
          imports =
            [
              ../../modules/options.nix
              ../../hosts/${hostname}/config.nix
              (lazyImport ../../hosts/${hostname}/nixos.nix)
            ]
            ++ (listModules
              |> (builtins.map (modName: [
                (lazyImport ../../modules/${modName}/options.nix)
                (lazyImport ../../modules/${modName}/nixos/default.nix)
              ]))
              |> my-lib.flatten);
        }

        # Home-sided modules
        (
          if (builtins.elem "home" module_types)
          then {
            imports = [
              inputs.home-manager.nixosModules.home-manager
            ];
            home-manager = {
              backupFileExtension = "bak";
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs my-lib;};
              users.${username} = {
                imports =
                  [
                    ../../modules/options.nix
                    ../../hosts/${hostname}/config.nix
                    (lazyImport ../../hosts/${hostname}/home.nix)
                    {
                      home.preferXdgDirectories = true;
                    }
                  ]
                  ++ (listModules
                    |> (builtins.map (modName: [
                      (lazyImport ../../modules/${modName}/options.nix)
                      (lazyImport ../../modules/${modName}/home/default.nix)
                    ]))
                    |> my-lib.flatten);
              };
            };
          }
          else {}
        )

        # Hjem-sided modules
        (
          if (builtins.elem "hjem" module_types)
          then {
            imports = [
              inputs.hjem.nixosModules.hjem
            ];
            hjem = {
              extraModules =
                [
                  ../../modules/options.nix
                  ../../hosts/${hostname}/config.nix
                  (lazyImport ../../hosts/${hostname}/hjem.nix)
                ]
                ++ (listModules
                  |> (builtins.map (modName: [
                    (lazyImport ../../modules/${modName}/options.nix)
                    (lazyImport ../../modules/${modName}/hjem/default.nix)
                  ]))
                  |> my-lib.flatten);
              specialArgs = {inherit inputs my-lib;};
              users.${username} = {
                enable = true;
                user = username;
                directory = "/home/${username}";
              };
            };
          }
          else {}
        )
      ];
    };

  mkSystemManagerSystem = {
    inputs,
    hostname,
  }:
    inputs.system-manager.lib.makeSystemConfig {
      modules =
        [../../modules/options.nix ../../hosts/${hostname}/system.nix]
        ++ (listModules
          |> (builtins.map (modName: [
            (lazyImport ../../modules/${modName}/options.nix)
            (lazyImport ../../modules/${modName}/system/default.nix)
          ]))
          |> my-lib.flatten);
    };
in {
  inherit mkNixosSystem mkSystemManagerSystem;
}
