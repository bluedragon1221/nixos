{pkgs, ...}: {
  imports = [
    ./emulators/foot.nix
    ./emulators/blackbox.nix

    ./programs/tmux
    ./programs/starship
    ./programs/cmus
    ./programs/bat.nix
    ./programs/helix.nix
    ./programs/eza.nix
    ./programs/fzf.nix

    ./shells/fish.nix
    ./shells/bash.nix
  ];

  config = {
    home.packages = with pkgs; [
      unzip
      zip
      ripgrep
      fd
      moreutils
      jq
      btop
    ];
  };
}
