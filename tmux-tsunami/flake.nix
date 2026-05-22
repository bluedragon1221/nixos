{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nix-std.url = "github:chessai/nix-std";
  };
  outputs = inputs: {
    hjemModules.tsunami = import ./modules/hjem.nix {
      std = inputs.nix-std.lib;
    };

    packages."x86_64-linux".tsunamiInstaller = let
      installer = import ./modules/installer.nix {
        pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
      };
    in
      installer.mkInstaller;
  };
}
