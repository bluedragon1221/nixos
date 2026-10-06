{pkgs, ...}: {
  systemd.network.netdevs."10-tap0" = {
    netdevConfig = {
      Name = "tap0";
      Kind = "tap";
    };
  };

  systemd.network.netdevs."10-mythra" = {
    netdevConfig = {
      Name = "mythra0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."20-mythra-bridge-bind" = {
    matchConfig.Name = ["enp56s0u1u4" "tap0"];
    networkConfig.Bridge = "mythra0";
  };

  systemd.network.networks."30-mythra-net" = {
    matchConfig.Name = "mythra0";
    networkConfig = {
      Address = "192.168.12.1/24";
    };
  };

  # systemd.services.windows-vm = {
  #   description = "QEMU Windows 11 IoT LTSC VM";
  #   wantedBy = ["multi-user.target"];
  #   after = ["network-online.target" "systemd-networkd.service"];
  #   wants = ["network-online.target"];

  #   serviceConfig = {
  #     Type = "simple";
  #     User = "root";

  #     ExecStart = ''
  #       ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
  #         -enable-kvm \
  #         -m 4096 \
  #         -smp 4 \
  #         -cpu host \
  #         -drive file=/media/windows.qcow2,format=qcow2 \
  #         -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
  #         -device e1000e,netdev=net0 \
  #         -nographic
  #     '';

  #     Restart = "on-failure";
  #     RestartSec = "10s";
  #   };
  # };
}
