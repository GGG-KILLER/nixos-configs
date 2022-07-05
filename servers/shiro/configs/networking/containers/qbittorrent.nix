{ config, ... }:

{
  my.networking.qbittorrent = {
    useVpn = true;
    extraNames = [ "flood" ];
    ipAddrs = {
      elan = "192.168.1.10";
      # clan = "192.168.2.10";
    };
    ports = [
      {
        protocol = "tcp";
        port = 6881;
        description = "DHT?";
      }
      {
        protocol = "udp";
        port = 6881;
        description = "DHT?";
      }
      {
        protocol = "http";
        port = 80;
        description = "Local NGINX";
      }
      {
        protocol = "http";
        port = config.modules.services.qbittorrent.web.port;
        description = "qBitTorrent Web UI";
      }
      {
        protocol = "http";
        port = config.modules.services.flood.web.port;
        description = "Flood UI";
      }
    ];
  };
}
