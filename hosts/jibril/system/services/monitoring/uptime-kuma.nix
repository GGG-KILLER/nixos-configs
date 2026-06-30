{ config, ... }: {
  jibril.dynamic-ports = [ "uptime-kuma" ];

  services.uptime-kuma.enable = true;
  services.uptime-kuma.settings = {
    NODE_EXTRA_CA_CERTS = config.security.pki.caBundle;
    PORT = toString config.jibril.ports.uptime-kuma;
  };

  # Allow reaching docker socket.
  systemd.services.uptime-kuma.serviceConfig.SupplementaryGroups = [ "docker" ];

  services.caddy.virtualHosts."status.jibril.lan".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString config.jibril.ports.uptime-kuma}
  '';
}
