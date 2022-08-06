{lib, ...}:
with lib; let
  portOptions = {
    options = {
      protocol = mkOption {
        type = types.enum ["http" "tcp" "udp"];
      };
      port = mkOption {
        type = types.port;
        description = "the port number";
      };
      description = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "the port's description";
      };
    };
  };
  networkingOptions = {name, ...}: {
    options = {
      name = mkOption {
        type = with types; str;
        default = name;
        description = "the name of this machine";
      };
      extraNames = mkOption {
        type = with types; listOf str;
        default = [];
        description = "extra hostnames for this machine";
      };
      useVpn = mkOption {
        type = types.bool;
        default = false;
        description = "whether to use VPN or not";
      };
      ipAddrs = mkOption {
        type = types.attrs;
        description = "the IP addresses of this machine";
      };
      ports = mkOption {
        type = with types; listOf (submodule portOptions);
        default = [];
        description = "the ports used by the machine";
      };
    };
  };
in {
  imports = [
    ./hosts.nix
    ./mitmproxy.nix
  ];

  options.my.networking = mkOption {
    type = with types; attrsOf (submodule networkingOptions);
  };

  options.my.constants.networking.vpnNameservers = mkOption {
    type = with types; listOf str;
    default = ["1.1.1.1" "8.8.8.8"];
    description = "the nameservers to use when a device is connected to the VPN";
  };

  config = rec {
    my.networking.shiro = {
      ipAddrs = {
        elan = "192.168.1.2";
      };
      extraNames = [
        "grafana.shiro"
        "prometheus.shiro"
        "monit.shiro"
        "ca"
      ];
    };

    networking = {
      useDHCP = false;
      enableIPv6 = false;
      hostName = "shiro";
      hostId = "14537a32";

      defaultGateway = "192.168.1.1";
      nameservers = ["192.168.1.1"];

      interfaces.enp6s0 = {
        ipv4.addresses = [];
      };

      macvlans.mv-enp6s0-host = {
        interface = "enp6s0";
        mode = "bridge";
      };
      interfaces.mv-enp6s0-host = {
        ipv4.addresses = [
          {
            address = my.networking.shiro.ipAddrs.elan;
            prefixLength = 24;
          }
        ];
      };
    };
  };
}
