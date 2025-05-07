{config, ...}: let
  cfg = config.collinux.user;
in {
  programs.git = {
    enable = true;
    userName = cfg.fullName;
    userEmail = cfg.email;
    aliases = {
      unstage = "restore --staged";
      stage = "add";
    };
    extraConfig = {
      init.defaultBranch = "main";

      gpg.format = "ssh";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
  };

  home.preferXdgDirectories = true;
}
