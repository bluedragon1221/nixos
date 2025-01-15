{
  cfgWrapper,
  pkgs,
}: let
  name = "Collin Williams";
  email = "96917990+bluedragon1221@users.noreply.github.com";
in
  cfgWrapper {
    pkg = pkgs.git;
    binName = "git";
    extraFlags = [
      ''-c user.name='${name}' ''
      ''-c user.email='${email}' ''
      ''-c init.defaultbranch='main' ''
    ];
  }
