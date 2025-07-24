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
    my.networking.jibril = {
      mainAddr = "192.168.2.2";
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
      hostName = "jibril";
      hostId = "023937b5";

      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];

      interfaces.enp0s31f6 = {
        ipv4.addresses = [
          {
            address = my.networking.jibril.mainAddr;
            prefixLength = 16;
          }
        ];
        wakeOnLan.enable = true;
      };

      hosts =
        let
          networking = mapAttrs (
            netName: netCfg: netCfg // { names = [ netCfg.name ] ++ netCfg.extraNames; }
          ) config.my.networking;
          hostToNameValPair = host: nameValuePair host.mainAddr (map (name: "${name}.lan") host.names);
        in
        listToAttrs (map hostToNameValPair (attrValues networking));
    };
  };
}
