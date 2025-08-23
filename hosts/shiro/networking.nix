{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    mapAttrs
    listToAttrs
    nameValuePair
    attrValues
    removeSuffix
    filter
    ;
  portOptions = {
    options = {
      protocol = mkOption {
        type = types.enum [
          "http"
          "tcp"
          "udp"
        ];
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
  networkingOptions =
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = with types; str;
          default = name;
          description = "the name of this machine";
        };
        extraNames = mkOption {
          type = with types; listOf str;
          default = [ ];
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
          default = [ ];
          description = "the ports used by the machine";
        };
      };
    };
in
{
  options.my.networking = mkOption { type = with types; attrsOf (submodule networkingOptions); };

  config = rec {
    my.networking.shiro = {
      mainAddr = "192.168.2.133"; # ipgen -n 192.168.2.0/24 shiro
      extraNames =
        [ ]
        ++ (map (name: removeSuffix ".lan" name) (
          filter (name: removeSuffix ".lan" name != name) (
            builtins.attrNames config.services.nginx.virtualHosts
          )
        ));
    };

    networking = {
      useDHCP = false;
      enableIPv6 = false;
      hostName = "shiro";
      hostId = "14537a32";

      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.2.2" ];

      interfaces.enp6s0 = {
        ipv4.addresses = [ ];
        wakeOnLan.enable = true;
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

      hosts =
        let
          networking = mapAttrs (
            netName: netCfg: netCfg // { names = [ netCfg.name ] ++ netCfg.extraNames; }
          ) config.my.networking;
          hostToNameValPair = host: nameValuePair host.mainAddr (map (name: "${name}.lan") host.names);
        in
        (listToAttrs (map hostToNameValPair (attrValues networking)))
        // {
          "192.168.2.2" = [
            "jibril.lan"
            "ca.lan docker.lan"
            "postgres.lan"
            "prometheus.jibril.lan"
            "sso.lan"
          ];
        };
    };
  };
}
