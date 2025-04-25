{pkgs, ...}: {
  home.packages = with pkgs; [
    unzip
    zip
    jq
    ripgrep
    btop
    fd
  ];

  programs.command-not-found.enable = false; # errors unless I use nix channels (eww)
  home.shell = {
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = true;
  };

  catppuccin.fish.enable = true;
  programs.fish = {
    enable = true;
    generateCompletions = true;
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza -A -w 80 --group-directories-first";
      tree = "${pkgs.eza}/bin/eza -T";
      cat = "${pkgs.bat}/bin/bat";
    };
    shellAbbrs = {
      nh = "nh os switch";
    };
    shellInit = ''
      set fish_greeting
    '';
  };

  # currently starship, fzf, and other catppuccin/nix cfgs use IFD, making them unusable to me.
  # IFD is a bug. I'll use them once their bugs are worked out. https://github.com/catppuccin/nix/issues/392

  catppuccin.fzf.enable = false;
  programs.fzf.enable = true;

  catppuccin.starship.enable = false;
  programs.starship = {
    enable = true;
    settings = {
      format = ''$directory$git_branch$git_status $character'';

      add_newline = false;
      scan_timeout = 10;

      character = {
        success_symbol = "[λ](green bold)";
        error_symbol = "[Σ](red bold)";
      };

      git_branch.format = "[@$branch](underline)";

      git_status = {
        format = "$modified$staged$ahead$behind";
        modified = "[!](red bold)";
        staged = "[+](green bold)";
        ahead = "[](green)";
        behind = "[](red)";
      };

      directory = {
        format = "$path";
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };
}
