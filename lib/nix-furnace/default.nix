let
  lazyImport = path:
    if (builtins.pathExists path)
    then import path
    else {};

  mkIfNull = cond: onTrue:
    if cond
    then onTrue
    else null;

  getSubdirs = dir:
    builtins.filter (x: x != null)
    (builtins.attrValues
      (builtins.mapAttrs
        (name: value: mkIfNull (value == "directory") name)
        (builtins.readDir dir)));

  getSubfiles = dir:
    builtins.filter (x: x != null)
    (builtins.attrValues
      (builtins.mapAttrs
        (name: value: mkIfNull (value == "file") name)
        (builtins.readDir dir)));

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
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
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
              extraSpecialArgs = {inherit inputs;};
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
