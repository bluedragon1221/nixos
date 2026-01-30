{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.system.audio;
in
  lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      pulse.enable = false;
    };

    boot.blacklistedKernelModules = ["snd_seq_dummy"]; # remove extraneous alsa midi devices

    environment.systemPackages = with pkgs; [pwvucontrol qpwgraph];

    users.users.${config.collinux.user.name}.extraGroups = ["audio" "pipewire"];
  }
