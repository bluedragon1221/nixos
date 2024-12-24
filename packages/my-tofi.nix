{
  cfgWrapper,
  pkgs,
}: let
  iosevka-ttf = pkgs.fetchzip {
    url = "https://github.com/be5invis/Iosevka/releases/download/v32.2.1/PkgTTF-IosevkaFixedSS01-32.2.1.zip";
    stripRoot = false;
    hash = "sha256-ejAIJR8mj7pMOLxUxN2VYKFo9stOvO7uN40dWJoepJw=";
  };
in
  cfgWrapper {
    pkg = pkgs.tofi;
    binName = "tofi-run";
    extraFlags = ["--font ${iosevka-ttf}/IosevkaFixedSS01-Medium.ttf"];
  }
