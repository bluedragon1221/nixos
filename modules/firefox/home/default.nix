{...}: {
  imports = [
    ./profile.nix
    ./theme_adwaita.nix
    ./theme_catppuccin.nix
  ];

  config = {
    programs.firefox.enable = true;
  };
}
