{
  collinux = {
    user.name = "collin";

    terminal = {
      programs = {
        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
        };
      };
    };

    boot.systemd-boot.enable = true;

    services = {
      networking = {
        enable = true;
        networkmanager.enable = true;
      };

      audio = {
        enable = true;
        pulse.enable = true;
      };

      selfhost = {
        navidrome.enable = true;
      };
    };
  };
}
