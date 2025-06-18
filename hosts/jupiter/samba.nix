{config, ...}: {
  users.users.${config.collinux.user.name}.extraGroups = ["brainusers"];
  users.users.bob = {
    isNormalUser = true;
    extraGroups = ["brainusers"];
    hashedPassword = "$y$j9T$L8CQv7V.LCD3gw/xR8M2T0$A4NHW9qpgc9pua7XE18P6ShICj.PNXHoyMW4yqmEMID";
  };

  users.groups."brainusers".name = "brainusers";

  # sudo smbpasswd -a collin <PASSWORD>
  # sudo smbpasswd -n bob # no password

  networking.firewall.allowedTCPPorts = [445];
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "brain2.0";
        "security" = "user";
        "map to guest" = "Bad User";

        # disable printing
        "load printers" = "no";
        "printing" = "bsd";
        "printcap name" = "/dev/null";
        "disable spoolss" = "yes";
      };

      "brain2.0-public" = {
        path = "/srv/brain";
        "read only" = "yes";
        "guest ok" = "yes";
        "force group" = "brainusers";
      };

      "brain2.0-admin" = {
        path = "/srv/brain";
        "read only" = "no";
        "valid users" = "collin";
        writeable = "yes";
        browseable = "yes";
        "guest ok" = "no";
        "create mask" = "0660";
        "directory mask" = "0770";
        "force group" = "brainusers";
      };

      "brain2.0-worldbuilding" = {
        path = "/srv/brain/notes/worldbuilding";
        "read only" = "no";
        "guest ok" = "yes";
        writeable = "yes";
        browseable = "yes";
        public = "yes"; # make windows not ask for password?
        "create mask" = "0660";
        "directory mask" = "0770";
        "force group" = "brainusers";

        "delete readonly" = "no"; # prevent deletion of the directory
      };
    };
  };
}
