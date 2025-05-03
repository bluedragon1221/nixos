{pkgs, ...}: {
  services.xserver = {
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-tour
    gnome-software
    gnome-console
  ];
}
