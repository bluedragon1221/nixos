{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
  pname = "lowfi";
  version = "0.1.0"; # Update with actual version

  src = builtins.fetchGit {
    url = "https://github.com/talwat/lowfi";
    rev = "a076c2b62faffd4541c18e7df44fd3cb361c93e5";
  };

  cargoHash = "sha256-ZMil+aZLAN3AZqFPIo69Dk3dmlosPT4A/5BGyA+vMNg="; # Will fail and show correct hash

  nativeBuildInputs = [pkgs.pkg-config];
  buildInputs = with pkgs; [openssl alsa-lib];
}
