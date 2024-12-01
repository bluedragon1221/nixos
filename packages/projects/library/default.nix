{pkgs}: let
  # package dependency
  epub_meta = let
    pname = "epub_meta";
    version = "0.0.7";
  in
    pkgs.python3Packages.buildPythonPackage {
      inherit pname version;
      src = pkgs.fetchFromGitHub {
        owner = "paulocheque";
        repo = "epub-meta";
        rev = "3cbbe936d97ec9b78918f6a4f4c8d4d3c89c29c6";
        sha256 = "sha256-Wor0sDLaNbPa+D3tcDfX208vRvEBDha4deCJOUkDU2I=";
      };
      doCheck = false;
    };
in
  pkgs.writeShellApplication {
    name = "library-app";
    runtimeInputs =
      [epub_meta pkgs.calibre]
      ++ (with pkgs.python3Packages; [
        fastapi
        jinja2
        python-multipart
        uvicorn
      ]);
    text = ''
      fastapi run --app ${./app}
    '';
  }
