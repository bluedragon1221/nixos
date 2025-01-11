{
  cfgWrapper,
  pkgs,
  my-helix,
  my-starship,
  my-git,
  my-tmux,
  hover-rs,
}: let
  my-bat = cfgWrapper {
    pkg = pkgs.bat;
    binName = "bat";
    extraEnv.BAT_THEME = "base16";
  };
in
  cfgWrapper {
    pkg = pkgs.fish;
    binName = "fish";

    extraFlags = ["--init-command 'source ${./config.fish}'"];

    extraPkgs =
      (with pkgs; [
        # broot
        eza
        entr
        fzf
        fd
        jq
        numbat
        ripgrep
        glow
        moreutils # includes vidir
        ouch # compression utility (zip, tar, rar, 7z, etc)
        unimatrix # cmatrix with more options
      ])
      ++ [my-git my-bat my-helix my-starship my-tmux hover-rs my-starship];

    hidePkgs = true;

    # disable command-not-found (its broken unless I use nix channels)
    postBuild = ''rm $out/share/fish/functions/fish_command_not_found.fish'';
  }
