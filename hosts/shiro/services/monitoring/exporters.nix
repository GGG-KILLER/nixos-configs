{ config, ... }:
{
  modules.services.lm-sensors-exporter.enable = true;
  modules.services.lm-sensors-exporter.listenAddress = config.my.networking.shiro.mainAddr;
  modules.services.lm-sensors-exporter.port = config.shiro.ports.prometheus-lm-sensors-exporter;
  networking.firewall.extraCommands = ''
    ip46tables -A nixos-fw -p tcp -m tcp -s 192.168.2.2 --dport ${toString config.modules.services.lm-sensors-exporter.port} -m comment --comment lm-sensors-exporter -j nixos-fw-accept
  '';

  services.prometheus.exporters.node.enable = true;
  services.prometheus.exporters.node.listenAddress = config.my.networking.shiro.mainAddr;
  services.prometheus.exporters.node.port = config.shiro.ports.prometheus-node-exporter;
  services.prometheus.exporters.node.openFirewall = true;
  services.prometheus.exporters.node.firewallFilter =
    "-p tcp -m tcp -s 192.168.2.2 --dport ${toString config.services.prometheus.exporters.node.port}";

  # NOTE: disabled for power saving.
  # services.prometheus.exporters.smartctl.enable = true;
  # services.prometheus.exporters.smartctl.listenAddress = config.my.networking.shiro.mainAddr;
  # services.prometheus.exporters.smartctl.port = config.shiro.ports.prometheus-smartmontools-exporter;
  # services.prometheus.exporters.smartctl.openFirewall = true;
  # services.prometheus.exporters.smartctl.firewallFilter =
  #   "-p tcp -m tcp -s 192.168.2.2 --dport ${toString config.services.prometheus.exporters.smartctl.port}";

  services.prometheus.exporters.zfs.enable = true;
  services.prometheus.exporters.zfs.listenAddress = config.my.networking.shiro.mainAddr;
  services.prometheus.exporters.zfs.port = config.shiro.ports.prometheus-zfs-exporter;
  services.prometheus.exporters.zfs.openFirewall = true;
  services.prometheus.exporters.zfs.firewallFilter =
    "-p tcp -m tcp -s 192.168.2.2 --dport ${toString config.services.prometheus.exporters.zfs.port}";
}
