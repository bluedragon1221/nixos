{pkgs}: let
  hycov-source = builtins.fetchGit {
    url = "https://github.com/DreamMaoMao/hycov";
    rev = "de15cdd6bf2e46cbc69735307f340b57e2ce3dd0";
  };
in
  pkgs.stdenv.mkDerivation {
    name = "hycov";
    src = hycov-source;
    buildInputs = with pkgs; [
      meson
      ninja
    ];
  }
