{ ... }:

{
  my.networking.network-share = {
    ipAddrs = {
      elan = "192.168.1.3";
      # clan = "192.168.2.3";
    };
    ports = [
      {
        protocol = "tcp";
        port = 139;
        description = "NetBIOS Session Service";
      }
      {
        protocol = "tcp";
        port = 445;
        description = "Microsoft DS";
      }
      {
        protocol = "udp";
        port = 137;
        description = "NetBIOS Name Service";
      }
      {
        protocol = "udp";
        port = 138;
        description = "NetBIOS Datagram Service";
      }
    ];
  };
}
