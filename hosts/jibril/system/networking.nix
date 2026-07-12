{ lib, config, ... }:
{
  networking = {
    useDHCP = false;
    hostName = "jibril";
    hostId = "023937b5";

    defaultGateway = config.home.addrs.router;
    nameservers = [ config.home.addrs.router ];

    interfaces.eno1 = {
      ipv4.addresses = [
        {
          address = config.home.addrs.jibril;
          prefixLength = 16;
        }
      ];
    };

    hosts."127.0.0.1" = (
      lib.filter (name: lib.removeSuffix ".lan" name != name) (
        lib.attrNames config.services.caddy.virtualHosts
      )
    );
  };
}
