{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) stdenv bun makeBinaryWrapper fetchFromGitHub;

  node_modules = stdenv.mkDerivation {
    pname = "copilot-api-node_modules";
    version = "0.7.0";

    src = fetchFromGitHub {
      owner = "ericc-ch";
      repo = "copilot-api";
      tag = "v0.7.0";
      hash = "sha256-rUUqf9QalVZDN3aw9ze5Uh+y5xvH6zdSgGN6ZLDjkDQ=";
    };

    nativeBuildInputs = [bun];

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    dontPatchShebangs = true;

    patchPhase = ''
      # Remove prepare script that tries to setup git hooks
      sed -i '/"prepare":/d' package.json
    '';

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      bun install --no-progress --frozen-lockfile
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R ./node_modules $out
      runHook postInstall
    '';

    outputHash = "sha256-+AH8eRG3SwwU86Pa/hFSW5nWD0v1po6z7xoLKUzq3qY=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
  stdenv.mkDerivation {
    pname = "copilot-api";
    version = "0.7.0";

    src = fetchFromGitHub {
      owner = "ericc-ch";
      repo = "copilot-api";
      tag = "v0.7.0";
      hash = "sha256-rUUqf9QalVZDN3aw9ze5Uh+y5xvH6zdSgGN6ZLDjkDQ=";
    };

    nativeBuildInputs = [makeBinaryWrapper];
    buildInputs = [bun pkgs.nodejs];

    configurePhase = ''
      runHook preConfigure
      # Don't copy node_modules - let bun install them fresh
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      # Use the cached node_modules
      cp -R ${node_modules}/node_modules .
      chmod -R +w node_modules
      # Try using bun's native build with correct entry point
      mkdir -p dist
      ${bun}/bin/bun build src/main.ts --outdir dist --target bun --format esm --sourcemap
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/copilot-api
      cp -r dist node_modules package.json $out/lib/copilot-api/

      mkdir -p $out/bin
      makeWrapper ${bun}/bin/bun $out/bin/copilot-api \
        --prefix PATH : ${lib.makeBinPath [bun]} \
        --add-flags "$out/lib/copilot-api/dist/main.js"

      runHook postInstall
    '';
  }
