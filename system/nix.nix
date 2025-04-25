{
  nix = {
    gc.automatic = false; # use nh cleaner instead

    # Make builds run with low priority so my system stays responsive
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      extra-experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/home/collin/nixos";
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (pkgs: super: {
        obsidian = pkgs.callPackage ../overlays/obsidian.nix {};
      })
    ];
  };
}
