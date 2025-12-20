{pkgs, ...}: {
  # auto-cpufreq
  services.power-profiles-daemon.enable = false; # conflicts with auto-cpufreq
  services.tlp.enable = false; # conflicts with auto-cpufreq
  services.thermald.enable = true; # does not conflict, recomended to run with auto-cpufreq
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        energy_performance_preference = "power";
        turbo = "never";
      };
    };
  };

  # Undervolt (BROKEN)
  # services.undervolt = {
  #   enable = true;
  #   useTimer = false;
  #   # power-limit-long
  #   p1 = {
  #     window = 1; # no clue what this means
  #     limit = 40;
  #   };

  #   # power-limit-short
  #   p2 = {
  #     window = 1;
  #     limit = 50;
  #   };

  #   coreOffset = -50; # also applied to cache
  #   gpuOffset = -10;
  # };

  # environment.systemPackages = with pkgs; [
  #   undervolt
  #   s-tui
  #   stress
  # ];
}
