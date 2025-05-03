{pkgs, ...}: {
  imports = [
    ../../system/battery.nix
    # ../../system/networking.nix
    ../../system/networking_iwd.nix

    ../../system/fonts.nix
    ../../system/desktops/hyprland.nix
  ];

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [foot.terminfo];

  system.stateVersion = "25.05";
}
