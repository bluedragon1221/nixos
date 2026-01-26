{
  config,
  lib,
  pkgs,
  ...
}: {
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

    # Disable channels
    channel.enable = false;
  };

  nixpkgs.config.allowUnfree = true;

  programs.nh = lib.mkIf config.collinux.terminal.programs.nh.enable {
    enable = true;
    flake = "/home/${config.collinux.user.name}/nixos";
    clean.enable = true;
  };

  environment.systemPackages = [pkgs.cached-nix-shell];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
