{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        # command = "${inputs.hyprland.packages."x86_64-linux".hyprland}/bin/Hyprland";
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "collin";
      };
      default_session = initial_session;
    };
  };
}
