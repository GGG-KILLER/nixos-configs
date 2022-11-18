{
  lib,
  config,
  ...
}:
with lib; {
  networking = {
    useDHCP = false;
    enableIPv6 = false;
    hostName = "shiro";
    hostId = "14537a32";

    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp6s0";
    };
    nameservers = ["192.168.1.1"];

    bridges = {
      # Bridge with LAN access
      br-ctlan = {
        interfaces = [];
      };
      # Bridge with VPN gateway only
      br-ctvpn = {
        interfaces = ["vlan-ctvpn"];
      };
    };

    interfaces = {
      enp6s0.ipv4.addresses = [
        {
          address = "192.168.1.2";
          prefixLength = 24;
        }
      ];
      vlan-ctvpn.virtual = true;
      br-ctlan.ipv4.addresses = [
        {
          address = "172.16.0.1";
          prefixLength = 24;
        }
      ];
      br-ctvpn.ipv4.addresses = [
        {
          address = "10.11.0.2";
          prefixLength = 24;
        }
      ];
    };

    # NAT br-ctlan to lan interface
    nat = {
      enable = true;
      internalInterfaces = ["br-ctlan"];
      externalInterface = "enp6s0";
    };

    # Causes issues with VPN and VLANs
    firewall.checkReversePath = false;
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };
}
