{pkgs, ...}: {
  boot = {
    initrd = {
      verbose = false;
      systemd.enable = true;
    };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
      timeout = 0; # spam space to get boot menu
    };

    plymouth = {
      enable = true;
      theme = "catppuccin-macchiato";
      themePackages = [pkgs.catppuccin-plymouth];
    };
  };
}
