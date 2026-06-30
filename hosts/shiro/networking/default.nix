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

  stripScheme =
    name:
    let
      m = builtins.match "https?://(.*)" name;
    in
    if m != null then builtins.head m else name;

  stripPort =
    name:
    let
      m = builtins.match "([^:]*):([0-9]+)" name;
    in
    if m != null then builtins.head m else name;

  extractCaddyHost = name: stripPort (stripScheme name);
  portOptions = {
    options = {
      protocol = mkOption {
        type = types.enum [
          "http"
          "https"
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
  imports = [ ./vpn.nix ];

  options.my.networking = mkOption { type = with types; attrsOf (submodule networkingOptions); };

  config = rec {
    my.networking.shiro = {
      mainAddr = config.home.addrs.shiro-main;
      extraNames =
        [ ]
        ++ (map (name: removeSuffix ".lan" name) (
          filter (name: removeSuffix ".lan" name != name) (
            map extractCaddyHost (builtins.attrNames config.services.caddy.virtualHosts)
          )
        ));
    };

    networking = {
      useDHCP = false;
      enableIPv6 = false;
      hostName = "shiro";
      hostId = "14537a32";

      defaultGateway = config.home.addrs.router;
      # DNS is handled by systemd-resolved with split routing (see ./vpn.nix).

      supplicant.enp6s0 = {
        driver = "wired";
        configFile.path = config.age.secrets."dot1x.conf".path;
      };

      interfaces.enp6s0.ipv4.addresses = [
        {
          address = my.networking.shiro.mainAddr;
          prefixLength = 16;
        }
      ];

      hosts =
        let
          networking = mapAttrs (
            netName: netCfg: netCfg // { names = [ netCfg.name ] ++ netCfg.extraNames; }
          ) config.my.networking;
          hostToNameValPair = host: nameValuePair host.mainAddr (map (name: "${name}.lan") host.names);
        in
        (listToAttrs (map hostToNameValPair (attrValues networking)))
        // {
          ${config.home.addrs.jibril} = [
            "jibril.lan"
            "ca.lan"
            "docker.lan"
            "postgres.lan"
            "prometheus.jibril.lan"
            "sso.lan"
          ];
        };
    };
  };
}
