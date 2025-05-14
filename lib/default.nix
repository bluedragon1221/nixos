{inputs, ...}: let
  lazyImport = path:
    if (builtins.pathExists path)
    then import path
    else {};

  mkIfList = cond: onTrue:
    if cond
    then onTrue
    else [];

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

  mkHomeImports = modName: [
    ../modules/${modName}/options.nix
    (lazyImport ../modules/${modName}/home/default.nix)
  ];
  mkSystemImports = modName: [
    ../modules/${modName}/options.nix
    (lazyImport ../modules/${modName}/system/default.nix)
  ];

  mkModules = mapFn: {
    imports =
      [../modules/options.nix]
      ++ (builtins.foldl' (a: b: a ++ b) [] (builtins.map mapFn (getSubdirs ../modules)));
  };

  mkHomeModules = mkModules mkHomeImports;
  mkSystemModules = mkModules mkSystemImports;

  mkHost = hostname: let
    preloadedConfig = import ../hosts/${hostname}/config.nix {inherit inputs;};
    username = preloadedConfig.collinux.user.name;

    isDisko = preloadedConfig.collinux.disko;
    isFacter = preloadedConfig.collinux.facter;
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules =
        [
          {networking.hostName = hostname;}

          mkSystemModules

          ../hosts/${hostname}/config.nix

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
                    ../hosts/${hostname}/config.nix
                  ]
                  ++ preloadedConfig.collinux.extraHomeModules;
              };
            };
          }
        ]
        ++ preloadedConfig.collinux.extraSystemModules
        ++ (mkIfList isDisko [
          inputs.disko.nixosModules.disko
          ../hosts/${hostname}/disks.nix
        ])
        ++ (mkIfList isFacter [
          inputs.nixos-facter-modules.nixosModules.facter
          {config.facter.reportPath = ../hosts/${hostname}/facter.json;}
        ]);
    };

  mkFurnace = {
    nixosConfigurations =
      builtins.listToAttrs
      (builtins.map (host: {
          name = host;
          value = mkHost host;
        })
        (getSubdirs ../hosts));
  };
in {
  inherit mkFurnace;
}
