{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "brain2.0";

        "security" = "user";
        "map to guest" = "bad user";
        "guest account" = "nobody";

        "bind interfaces only" = "no";
        "interfaces" = "lo wlp2s0";

        # disable printing
        "load printers" = "no";
        "printing" = "bsd";
        "printcap name" = "/dev/null";
        "disable spoolss" = "yes";
      };

      "brain2.0" = {
        comment = "";
        path = "/srv/brain";
        browseable = "yes";
        "guest ok" = "yes";
        "read only" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";

        "write list" = "";
        "valid users" = "@users, guest";

        # Hide guest-editable dirs
        "veto files" = "/notes/worldbuilding/";
      };

      "brain2.0-admin" = {
        comment = "";
        path = "/srv/brain";
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = "collin";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      "brain2.0-worldbuilding" = {
        comment = "";
        path = "/srv/brain/notes/worldbuilding";
        browseable = "yes";
        "guest ok" = "yes";
        "read only" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force create mode" = "0664";
        "force directory mode" = "0775";

        "write list" = "@users, guest";
        "valid users" = "@users, guest";

        "delete readonly" = "no"; # prevent deletion of the directory
      };
    };
  };
}
