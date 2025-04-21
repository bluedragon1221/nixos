{pkgs, ...}: {
  services.pipewire = {
    enable = true;
    pulse.enable = false;
    wireplumber.enable = true;
    alsa.enable = true;
  };
}
