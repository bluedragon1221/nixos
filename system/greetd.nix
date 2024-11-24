{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = rec {initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "collin";
      };
      default_session = initial_session;
    };
  };
}

