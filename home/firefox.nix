{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    profiles."collin" = {
      containersForce = true;
      containers = {
        "school" = {
          color = "orange";
          icon = "briefcase";
          id = 2;
        };
        "P-TECH" = {
          color = "purple";
          icon = "dollar";
          id = 3;
        };
        "personal" = {
          color = "blue";
          icon = "fingerprint";
          id = 1;
        };
      };
      userChrome = ''
        #alltabs-button {
          display: none !important;
        }
      '';
    };
  };
}
