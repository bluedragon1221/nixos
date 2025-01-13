{
  cfgWrapper,
  pkgs,
}:
cfgWrapper {
  pkg = pkgs.cava;
  binName = "cava";
  extraFlags = ["-p ${./cava}"];
}
