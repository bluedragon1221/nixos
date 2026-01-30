{lib, ...}: let
  defaultDenyRule = ''
    polkit.addRule(function(action, subject) {
      // Log denied actions for debugging
      polkit.log("DENY: action=" + action.id + " user=" + subject.user);
      return polkit.Result.NO;
    });
  '';

  run0Rules = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel") && action.id === "org.freedesktop.systemd1.manage-units") {
        return polkit.Result.AUTH_ADMIN_KEEP;
      }
    });
  '';

  networkRules = ''
    polkit.addRule(function(action, subject) {
      // Only allow network modifications for wheel group (admins)
      if (action.id.startsWith("org.freedesktop.NetworkManager.") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }

      // Allow reading network status for all users
      if (action.id == "org.freedesktop.NetworkManager.network-control" ||
          action.id == "org.freedesktop.NetworkManager.settings.modify.system") {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
        return polkit.Result.NO;
      }

      return polkit.Result.NOT_HANDLED;
    });
  '';

  powerRules = ''
    polkit.addRule(function(action, subject) {
      if (action.id.match("org.freedesktop.login1.")) {
        return polkit.Result.YES;
      }
    });
  '';

  bluetoothRules = ''
    polkit.addRule(function(action, subject) {
      // Allow users to manage bluetooth devices
      if (action.id.startsWith("org.bluez.") &&
          subject.local && subject.active) {
        return polkit.Result.YES;
      }

      return polkit.Result.NOT_HANDLED;
    });
  '';
in {
  security = {
    polkit = {
      enable = true;
      adminIdentities = ["unix-group:wheel"];

      extraConfig = lib.concatStringsSep "\n\n" [
        run0Rules
        networkRules
        powerRules
        bluetoothRules
        defaultDenyRule
      ];
    };

    soteria.enable = true;
  };
}
