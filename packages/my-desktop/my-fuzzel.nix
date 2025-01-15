{
  cfgWrapper,
  pkgs,
  my-kitty,
  my-firefox,
}: let
  settings = pkgs.writeText "fuzzel.ini" ''
    [colors]
    background=24273add
    text=cad3f5ff
    prompt=b8c0e0ff
    placeholder=8087a2ff
    input=cad3f5ff
    match=8aadf4ff
    selection=5b6078ff
    selection-text=cad3f5ff
    selection-match=8aadf4ff
    counter=8087a2ff
    border=8aadf4ff

    [main]
    dpi-aware=no
    prompt="  "

    font=Iosevka Nerd Font:size=13
    line-height=25
    lines=10
    width=30

    horizontal-pad=8
    vertical-pad=8

    [border]
    radius=0
    width=2
  '';

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
    binName = "fuzzel";

    extraFlags = ["--config=${settings}" "--hide-before-typing"];
    extraWrapperFlags = ["--prefix XDG_DATA_DIRS : ${extraDesktopFiles}/share"];
  }
