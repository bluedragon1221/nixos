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
            preferXdgDirectories = true;
            stateVersion = "24.05";
          };
          programs.home-manager.enable = true;
        }

        ./hyprland.nix
        ./vscode.nix
        ./cursor.nix
      ];
    };
  };
}
