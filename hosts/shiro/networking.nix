{
  lib,
  config,
  ...
}:
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
      mainAddr = mkOption {
        type = types.str;
        description = "the main IP address of this machine";
      };
      extraAddrs = mkOption {
        type = with types; attrsOf str;
        description = "extra IP addresses that may be used to reach this machine";
      };
      ports = mkOption {
        type = with types; listOf (submodule portOptions);
        default = [];
        description = "the ports used by the machine";
      };
    };
  };
in {
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
      mainAddr = "192.168.1.2";
      extraAddrs = {
        ctlan = "10.0.0.1";
        ctvpn = "10.0.1.2";
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
            address = my.networking.shiro.mainAddr;
            prefixLength = 24;
          }
        ];
        vlan-ctvpn.virtual = true;
        br-ctlan.ipv4.addresses = [
          {
            address = my.networking.shiro.extraAddrs.ctlan;
            prefixLength = 24;
          }
        ];
        br-ctvpn.ipv4.addresses = [
          {
            address = my.networking.shiro.extraAddrs.ctvpn;
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

      # hosts = let
      #   networking = mapAttrs (netName: netCfg: netCfg // {names = [netCfg.name] ++ netCfg.extraNames;}) config.my.networking;
      #   hostToNameValPair = host: nameValuePair host.mainAddr (map (name: "${name}.local") host.names);
      # in
      #   listToAttrs (map hostToNameValPair (attrValues networking));
    };

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };
  };
}
