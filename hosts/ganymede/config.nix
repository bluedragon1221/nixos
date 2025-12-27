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
        static = {
          enable = true;
          ssid = "williams";
          pskFile = "williams-psk";
          ip = "192.168.50.2";
          gateway = "192.168.50.1";
        };
        tailscale.enable = true;
        sshd.enable = true;
      };

      selfhost = {
        adguard.enable = true;
        caddy.enable = true;
      };
    };
  };
}
