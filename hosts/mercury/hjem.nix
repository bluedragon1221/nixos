{pkgs, ...}: let
  rust-shell = let
    rustProfile = pkgs.buildEnv {
      name = "rust-profile";
      paths = with pkgs; [rustc cargo rust-analyzer];
    };
  in
    pkgs.writeShellScriptBin "rust-shell" ''
      export PATH="${rustProfile}/bin:$PATH"
      export RUST_BACKTRACE=1
      exec $SHELL
    '';

  py-shell = let
    pythonProfile = pkgs.python314.withPackages (ps:
      with ps; [
        numpy
        matplotlib
        pandas
        jupyter
        ipython
      ]);
  in
    pkgs.writeShellScriptBin "py-shell" ''
      export PATH="${pythonProfile}/bin:$PATH"
      export PYTHONSTARTUP=""
      exec $SHELL
    '';
in {
  packages = with pkgs; [
    anki
    libreoffice-qt
    musescore
    vscodium

    noctalia-shell

    prismlauncher
    mpv
    irssi

    (pkgs.callPackage ../../pkgs/yo {})

    rust-shell
    py-shell
  ];
}
