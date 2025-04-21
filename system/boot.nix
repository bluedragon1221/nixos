{pkgs, ...}: {
  boot = {
    initrd = {
      verbose = false;
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [];
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };

    plymouth = {
      enable = true;
      theme = "catppuccin-macchiato";
      themePackages = [pkgs.catppuccin-plymouth];
    };
    
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [];
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.firmware = [pkgs.linux-firmware];
}
