{
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
}
