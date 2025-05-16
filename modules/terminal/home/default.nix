{pkgs, ...}: let
  findPrograms =
    builtins.attrValues
    (builtins.mapAttrs
      (file: type: ./programs/${file})
      (builtins.readDir ./programs));
in {
  imports =
    [
      ./emulators/foot.nix
      ./emulators/blackbox.nix

      ./shells/fish.nix
      ./shells/bash.nix
    ]
    ++ findPrograms;

  config = {
    home.packages = with pkgs; [
      unzip
      zip
      ripgrep
      fd
      moreutils
      jq
      btop
    ];
  };
}
