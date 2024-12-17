{
  cfgWrapper,
  pkgs,
}: let
  iosevka-ttf =
    pkgs.runCommand "iosevka-ttf" {
      buildInputs = [pkgs.wget];
    } ''
      wget "https://github.com/be5invis/Iosevka/releases/download/v32.2.1/PkgTTF-IosevkaFixedSS01-32.2.1.zip"
      unzip *.zip
    '';
in
  cfgWrapper {
    pkg = pkgs.tofi;
    extraFlags = ["--font ${iosevka-ttf}/IosevkaFixedSS01-Medium.ttf"];
  }
