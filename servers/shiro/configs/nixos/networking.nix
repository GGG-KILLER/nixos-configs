{ config, ... }:

{
  networking = {
    useDHCP = false;
    enableIPv6 = false;
    hostName = "shiro";
    hostId = "14537a32";

    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];

    interfaces.enp6s0 = {
      ipv4.addresses = [ ];
    };

    # # Bridge Fuckery

    # bridges = {
    #   vmbr0.interfaces = [ "enp6s0" ];
    #   vmbr1.interfaces = [ ];
    # };

    # interfaces.vmbr0 = {
    #   ipv4.addresses = [{
    #     address = config.my.networking.shiro.ipAddrs.elan;
    #     prefixLength = 24;
    #   }];
    # };

    # interfaces.vmbr1 = {
    #   ipv4.addresses = [{
    #     address = config.my.networking.shiro.ipAddrs.clan;
    #     prefixLength = 24;
    #   }];
    # };

    macvlans.mv-enp6s0-host = {
      interface = "enp6s0";
      mode = "bridge";
    };
    interfaces.mv-enp6s0-host = {
      ipv4.addresses = [{
        address = config.my.networking.shiro.ipAddrs.elan;
        prefixLength = 24;
      }];
    };
  };
}
