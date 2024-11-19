{ pkgs, ... }: pkgs.rustPlatform.buildRustPackage {
  pname = "hover";
  version = "1.0";

  src = builtins.fetchGit {
    url = "https://github.com/viperML/hover-rs";
    rev = "7a699b1e8a52c416e6d113a000b500752a6c3371";
  };

  cargoHash = "sha256-2SL4oLw93O5rzgVEvvMfAOCqf094NbI9k2IOsiESeYM=";
}
