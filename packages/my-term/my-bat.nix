{
  cfgWrapper,
  pkgs,
}:
cfgWrapper {
  pkg = pkgs.bat;
  extraEnv.BAT_THEME = "base16";
}
