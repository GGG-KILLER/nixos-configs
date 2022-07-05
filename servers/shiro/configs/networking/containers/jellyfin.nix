{ ... }:

{
  my.networking.jellyfin = {
    useVpn = true;
    ipAddrs = {
      elan = "192.168.1.6";
      # clan = "192.168.2.6";
    };
    ports = [
      {
        protocol = "http";
        port = 8096;
        description = "Jellyfin Web UI";
      }
      {
        protocol = "http";
        port = 80;
        description = "Local NGINX";
      }
    ];
  };
}
