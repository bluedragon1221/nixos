{
  cfgWrapper,
  pkgs,
  my-kitty,
  my-firefox,
}: let
  extraDesktopFiles = pkgs.symlinkJoin {
    name = "extra-desktop-files";
    paths = [
      (pkgs.makeDesktopItem {
        name = "kitty";
        desktopName = "Kitty";
        exec = "${my-kitty}/bin/kitty";
        icon = "kitty";
      })
      (pkgs.makeDesktopItem {
        name = "firefox";
        desktopName = "Firefox";
        exec = "${my-firefox}/bin/firefox";
        icon = "firefox";
      })
    ];
  };
in
  cfgWrapper {
    pkg = pkgs.fuzzel;

    extraFlags = ["--config=${./fuzzel.ini}" "--hide-before-typing"];
    extraWrapperFlags = ["--prefix XDG_DATA_DIRS : ${extraDesktopFiles}/share"];
  }
