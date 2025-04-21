{
  programs.git = {
    enable = true;
    userName = "Collin Williams";
    userEmail = "96917990+bluedragon1221@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
    aliases = {
      unstage = "restore --staged";
      stage = "add";
    };
  };
}
