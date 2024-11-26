{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.my-hyprland}/bin/Hyprland";
        user = "collin";
      };
      default_session = initial_session;
    };
  };
}
