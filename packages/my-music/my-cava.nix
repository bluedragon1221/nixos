{
  cfgWrapper,
  pkgs,
}:
cfgWrapper {
  pkg = pkgs.cava;
  extraFlags = ["-p ${./cava_config}"];
}
