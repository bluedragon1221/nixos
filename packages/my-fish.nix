{
  cfgWrapper,
  pkgs,
  my-helix,
  my-starship,
  my-git,
  my-tmux,
  hover-rs,
}: let
  shellInit = pkgs.writeText "config.fish" ''
    # ugly greeting gone
    set fish_greeting

    # prompt
    ${my-starship}/bin/starship init fish | source
    ${pkgs.fzf}/bin/fzf --fish | source

    # aliases
    abbr -a nh nh os switch
    abbr -a ga --set-cursor "git add %"
    abbr -a gc --set-cursor "git commit -m '%'"
    abbr -a gp "git push"

    alias ls '${pkgs.eza}/bin/eza -A -w 80 --group-directories-first'
    alias tree '${pkgs.eza}/bin/eza -T'
    alias icat 'kitten icat'

    alias cat '${pkgs.bat}/bin/bat'
    alias bc '${pkgs.numbat}/bin/numbat'

    # environment variables
    set -x EDITOR hx
    set -x VISUAL hx

    set -x XDG_DATA_HOME ~/.local/share
    set -x XDG_CONFIG_HOME ~/.config
    set -x XDG_STATE_HOME ~/.local/state
    set -x XDG_CACHE_HOME ~/.cache

    set -x CARGO_HOME $XDG_DATA_HOME/cargo
    set -x PYTHON_HISTORY $XDG_DATA_HOME/python/python_history
    set -x GOPATH $XDG_DATA_HOME/go
    set -x HISTFILE $XDG_DATA_HOME/bash/history # for children bash sessions
  '';
in
  cfgWrapper {
    pkg = pkgs.fish;
    binName = "fish";

    extraFlags = ["--init-command 'source ${shellInit}'"];

    extraPkgs =
      (with pkgs; [
        # broot
        entr
        fzf
        fd
        jq
        bat
        numbat
        ripgrep
        glow
        moreutils # includes vidir
        ouch # compression utility (zip, tar, rar, 7z, etc)
        unimatrix # cmatrix with more options
      ])
      ++ [my-git my-helix my-starship my-tmux hover-rs];

    hidePkgs = true;

    # disable command-not-found (its broken unless I use nix channels)
    postBuild = ''rm $out/share/fish/functions/fish_command_not_found.fish'';
  }
