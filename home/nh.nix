{config, ...}: {
  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/home/${config.home.username}/nixos";
  };
}
