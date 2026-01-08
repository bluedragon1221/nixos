let
  my-lib = import ../lib.nix;
  inherit (my-lib.globimport) getSubdirs lazyImport;

  listModules = getSubdirs ../../modules;

  mkNixosSystem = {
    inputs,
    hostname,
    username,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs my-lib;};
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

        # Hjem-sided modules
        {
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
      ];
    };
in {
  inherit mkNixosSystem;
}
