{pkgs, ...}:
pkgs.buildGoModule {
  name = "yokey";
  src = ./.;
  vendorHash = "sha256-utqr6tHvWmXe+9sV4Nul0EYTUOyWp/e4mcfiINdxkfc=";
}
