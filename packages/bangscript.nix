{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
  pname = "bangscript";
  version = "0.0.0";

  src = builtins.fetchGit {
    url = "https://github.com/viperML/bangscript";
    rev = "c319db25c831f3d10b7cbb3ba97c6ddd6c229f00";
  };

  cargoHash = "";
}
