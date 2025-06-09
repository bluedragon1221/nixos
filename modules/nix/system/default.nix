{
  nix = {
    gc.automatic = false; # use nh cleaner instead

    # Make builds run with low priority so my system stays responsive
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      extra-experimental-features = ["nix-command" "flakes" "pipe-operators"];
      auto-optimise-store = true;
      use-xdg-base-directories = true;
    };
  };

  # Disable channels
  nix.channel.enable = false;
  programs.command-not-found.enable = false; # breaks unless you use channels

  nixpkgs = {
    config.allowUnfree = true;
  };
}
