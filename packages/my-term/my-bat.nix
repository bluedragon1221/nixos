{
  cfgWrapper,
  pkgs,
}:
cfgWrapper {
  pkg = pkgs.bat;
  binName = "bat";
  extraEnv.BAT_THEME = "base16";
}
