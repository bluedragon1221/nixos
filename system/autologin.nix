{pkgs, ...}: {
  programs.uwsm = {
    enable = true;
  };


  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.uwsm}/bin/uwsm start default";
        user = "collin";
      };
      default_session = initial_session;
    };
  };
}
