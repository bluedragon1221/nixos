{pkgs, ...}: {
  services.xserver = {
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    gnome.enable = true;
  };
}
