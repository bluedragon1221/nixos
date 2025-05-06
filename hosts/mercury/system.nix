{pkgs, ...}: {
  imports = [
    ../../system/battery.nix

    ../../system/fonts.nix
    ../../system/desktops/hyprland.nix
  ];

  services.blueman.enable = true;

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [foot.terminfo];

  system.stateVersion = "25.05";
}
