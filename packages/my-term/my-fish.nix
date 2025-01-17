{
  cfgWrapper,
  pkgs,
  extraApplications ? [],
}: let
  basicApplications = with pkgs; [
    eza
    entr
    fzf
    fd
    jq
    numbat
    ripgrep
    glow
    moreutils # for vidir
    ouch # compression utility (zip, tar, rar, 7z, etc)
    unimatrix # cmatrix with more options
  ];
in
  cfgWrapper {
    pkg = pkgs.fish;

    extraFlags = ["--init-command 'source ${./config.fish}'"];

    extraPkgs = basicApplications ++ extraApplications;
    hidePkgs = true;

    # disable command-not-found (its broken unless I use nix channels)
    postBuild = ''rm $out/share/fish/functions/fish_command_not_found.fish'';
  }
