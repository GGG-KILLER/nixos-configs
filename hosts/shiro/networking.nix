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
            address = my.networking.shiro.mainAddr;
            prefixLength = 16;
          }
        ];
      };

      hosts = let
        networking = mapAttrs (netName: netCfg: netCfg // {names = [netCfg.name] ++ netCfg.extraNames;}) config.my.networking;
        hostToNameValPair = host: nameValuePair host.mainAddr (map (name: "${name}.lan") host.names);
      in
        listToAttrs (map hostToNameValPair (attrValues networking));
    };
  };
}
