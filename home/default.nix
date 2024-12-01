{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs pkgs;};
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    users.collin = {
      imports = [
        {
          home = {
            username = "collin";
            homeDirectory = "/home/collin";
            stateVersion = "24.05";
          };
          programs.home-manager.enable = true;
        }

        ./vscode.nix
      ];
    };
  };
}
