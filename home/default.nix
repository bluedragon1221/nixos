{pkgs, inputs, ...}: {
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
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

        ./hyprland.nix
        ./vscode.nix
      ];
    };
  };
}
