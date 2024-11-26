{
  pkgs,
  inputs,
  ...
}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs pkgs;};
    backupFileExtension = "bak";
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
