{ config, options, lib, ... }:

with lib;
let
  consts = config.my.constants;
  hostNetCfg = config.my.networking.shiro;
  vpnNetCfg = config.my.networking.vpn-gateway;
in
rec {
  mkDefaultSettings =
    { name
    , includeAnimu ? true
    , includeH ? true
    , includeEtc ? true
    , ...
    }:
    let
      netCfg = config.my.networking.${name};
      ipAddr = netCfg.ipAddrs;
      clanHash = substring 0 10 (builtins.hashString "sha1" name);
    in
    {
      # This can be overriden by just defining it.
      autoStart = true;
      privateNetwork = true;

      # External LAN
      macvlans = mkIf (netCfg.ipAddrs ? elan) [ "enp6s0" ];

      # Container LAN
      extraVeths = {
        "clan-${clanHash}" = mkIf (netCfg.ipAddrs ? clan) {
          hostBridge = "vmbr1";
          localAddress = "${netCfg.ipAddrs.clan}/24";
        };
      };

      bindMounts = mkMerge [
        (optionalAttrs includeAnimu {
          "/mnt/animu" = {
            hostPath = "/zfs-main-pool/data/animu";
            isReadOnly = false;
          };
        })
        (optionalAttrs includeH {
          "/mnt/h" = {
            hostPath = "/zfs-main-pool/data/h";
            isReadOnly = false;
          };
        })
        (optionalAttrs includeEtc {
          "/mnt/etc" = {
            hostPath = "/zfs-main-pool/data/etc";
            isReadOnly = false;
          };
        })
      ];

      config = { config, pkgs, ... }:
        let
          containerCfg = config.container;
        in
        {
          imports = [
            ../../../configs
            ../configs/networking/containers
            ../configs/networking/hosts.nix
            ../configs/nixos/gpu.nix
            ../../../overlays
          ];

          options.container = {
            name = mkOption {
              type = types.str;
              description = "The name of the container";
            };
            nameservers = mkOption {
              type = types.listOf types.str;
              description = "The list of nameservers used by the container";
              default = [ "192.168.1.1" ];
            };
          };

          config = {
            container.name = name;

            # Enable X11 Libs
            environment.noXlibs = false;

            # Base network configs
            networking = {
              useDHCP = mkOverride 900 false;
              enableIPv6 = mkOverride 900 false;
              hostName = name;
              defaultGateway = mkOverride 900 (
                if netCfg.useVpn
                then
                  if ipAddr ? clan
                  then vpnNetCfg.ipAddrs.clan
                  else vpnNetCfg.ipAddrs.elan
                else "192.168.1.1"
              );
              nameservers =
                if netCfg.useVpn
                then consts.networking.vpnNameservers
                else containerCfg.nameservers;
              interfaces = {
                mv-enp6s0.ipv4.addresses = mkIf (ipAddr ? elan) [{
                  address = ipAddr.elan;
                  prefixLength = 24;
                }];
                "clan-${clanHash}".ipv4.addresses = mkIf (ipAddr ? clan) [{
                  address = ipAddr.clan;
                  prefixLength = 24;
                }];
              };
              firewall =
                let
                  getPorts = proto:
                    flatten (map (portDef: portDef.port) (filter (portDef: portDef.protocol == proto) netCfg.ports));
                in
                {
                  allowedTCPPorts = getPorts "tcp" ++ getPorts "http";
                  allowedUDPPorts = getPorts "udp";
                };
            };

            # Enable the OpenSSH server.
            services.sshd.enable = true;

            # Have manpages
            environment.systemPackages = with pkgs; [ man git netcat tcpdump htop nmon ];
          };
        };
    };

  mkContainer = config: mkMerge [
    (mkDefaultSettings config)
    (filterAttrs (name: val: all (unwantedName: name != unwantedName) [ "name" "includeAnimu" "includeH" "includeEtc" ]) config)
  ];
}
