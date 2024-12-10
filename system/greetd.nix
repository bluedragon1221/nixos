{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = let
      s = {
        command = "${pkgs.my-hyprland}/bin/Hyprland";
        user = "collin";
      };
    in {
      initial_session = s;
      default_session = s;
    };
  };
}
