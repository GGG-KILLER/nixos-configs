{ config, ... }:

{
  my.networking.sonarr = {
    useVpn = true;
    extraNames = [ "jackett" ];
    ipAddrs = {
      elan = "192.168.1.5";
      # clan = "192.168.2.5";
    };
    ports = [
      {
        protocol = "http";
        port = 8989;
        description = "Sonarr Web UI";
      }
      {
        protocol = "http";
        port = 9117;
        description = "Jackett Web UI";
      }
      {
        protocol = "http";
        port = 80;
        description = "NGINX";
      }
    ];
  };
}
