{
  cfgWrapper,
  pkgs,
}:
cfgWrapper {
  pkg = pkgs.bat;
  extraEnv.BAT_THEME = "base16";
  extraEnv.BAT_PAGER = "0"; # Disable paging (prefer tmux pager)
}
