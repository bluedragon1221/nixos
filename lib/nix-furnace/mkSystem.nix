let
  my-lib = import ../lib.nix;
  inherit (my-lib.globimport) getSubdirs lazyImport;

  hosts = (builtins.fromTOML (builtins.readFile ../../hosts.toml)).hosts;

  listModules = getSubdirs ../../modules;

  nixosModules = hostname:
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

  hjemModules = hostname:
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

  mkNixosSystem = {
    inputs,
    hostname,
    username,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs my-lib hosts;};
      modules = [
        {networking.hostName = hostname;}

        ../../hosts/${hostname}/config.nix

        # Nixos-sided modules
        {imports = nixosModules hostname;}

        # Hjem-sided modules
        {
          imports = [
            inputs.hjem.nixosModules.hjem
          ];
          hjem = {
            extraModules = hjemModules hostname;
            specialArgs = {inherit inputs my-lib hosts;};
            users.${username} = {
              enable = true;
              user = username;
              directory = "/home/${username}";
            };
          };
        }
      ];
    };

  genDocs = {
    lib,
    pkgs,
    inputs,
    hostname,
    ...
  }: let
    eval = lib.evalModules {
      modules = listModules |> (builtins.map (m: (lazyImport ../../modules/${m}/options.nix)));
      specialArgs = {
        inherit my-lib pkgs;
      };
      check = false;
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit (eval) options;
    };
  in
    pkgs.runCommand "options-doc.md" {
      buildInputs = [pkgs.pandoc];
    } ''
      mkdir -p $out
      cat ${optionsDoc.optionsCommonMark} | pandoc -t html -o - | tee $out/index.html
    '';
in {
  inherit mkNixosSystem genDocs;
}
