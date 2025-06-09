let
  my-lib = import ../lib.nix;
  inherit (my-lib.globimport) lazyImport getSubdirs getSubfiles;

  mkHomeImports = modName: [
    (lazyImport ../../modules/${modName}/options.nix)
    (lazyImport ../../modules/${modName}/home/default.nix)
  ];
  mkSystemImports = modName: [
    (lazyImport ../../modules/${modName}/options.nix)
    (lazyImport ../../modules/${modName}/system/default.nix)
  ];

  mkModules = mapFn: {
    imports =
      [../../modules/options.nix]
      ++ (builtins.foldl' (a: b: a ++ b) [] (builtins.map mapFn (getSubdirs ../../modules)));
  };

  mkHomeModules = mkModules mkHomeImports;
  mkSystemModules = mkModules mkSystemImports;

  mkHost = {
    hostname,
    namespace,
    inputs,
    ...
  }: let
    preloadedConfig = import ../../hosts/${hostname}/config.nix {inherit inputs;};
    username = preloadedConfig."${namespace}".user.name;

    furnaceOptions = {lib, ...}: let
      inherit (lib) mkOption types;
    in {
      options.nix-furnace = {
        extraHomeModules = mkOption {
          type = with types; listOf path;
          default = [];
        };

        extraSystemModules = mkOption {
          type = with types; listOf path;
          default = [];
        };
      };
    };

    specialArgs = {inherit inputs my-lib;};
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      modules =
        [
          {networking.hostName = hostname;}

          ../../hosts/${hostname}/config.nix

          mkSystemModules

          furnaceOptions

          # Home-manager
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "bak";
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users."${username}" = {
                imports =
                  [
                    mkHomeModules

                    furnaceOptions

                    ../../hosts/${hostname}/config.nix
                  ]
                  ++ preloadedConfig.nix-furnace.extraHomeModules;
              };
            };
          }
        ]
        ++ preloadedConfig.nix-furnace.extraSystemModules;
    };

  mkFlake = {
    namespace,
    inputs,
    ...
  }: {
    nixosConfigurations =
      builtins.listToAttrs
      (builtins.map (hostname: {
          name = hostname;
          value = mkHost {inherit inputs hostname namespace;};
        })
        (getSubdirs ../../hosts));
  };
in {
  inherit mkFlake;
}
