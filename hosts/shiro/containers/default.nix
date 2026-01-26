{
  self,
  system,
  inputs,
  options,
  config,
  lib,
  pkgs,
  liveCd,
  ...
}:
with lib;
{
  imports = [
    ./downloads
    ./streaming
    ./vpn-gateway.nix
  ];

  options.modules.containers =
    let
      containerOptions = options.containers.type.getSubOptions [
        "modules"
        "containers"
      ];
    in
    mkOption {
      type =
        with types;
        attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                name = mkOption {
                  description = "The container name (if not set uses the key in the modules.containers object)";
                  type = types.str;
                  default = name;
                };

                vpn = mkEnableOption "Whether this container should be tunneled through the VPN";

                # Allows the container to create and setup tunnel interfaces by granting the `NET_ADMIN` capability and enabling access to `/dev/net/tun`.
                inherit (containerOptions) enableTun;
                # Extra veth-pairs to be created for the container.
                inherit (containerOptions) extraVeths;
                # List of forwarded ports from host to container.
                # Each forwarded port is specified by protocol, hostPort and containerPort.
                # By default, protocol is tcp and hostPort and containerPort are assumed to be the same if containerPort is not explicitly given.
                inherit (containerOptions) forwardPorts;

                # Runs container in ephemeral mode with the empty root filesystem at boot.
                # Useful for completely stateless, reproducible containers.
                ephemeral = mkOption {
                  type = containerOptions.ephemeral.type;
                  description = containerOptions.ephemeral.description;
                  default = true;
                };

                # Time for the container to start. In case of a timeout, the container processes get killed.
                inherit (containerOptions) timeoutStartSec;

                # Enable adding extra flags to the systemd-nspawn command line.
                inherit (containerOptions) extraFlags;

                builtinMounts = mkOption {
                  description = "Which of the builtin mounts should be mounted into this container";
                  type = types.submodule {
                    options = {
                      animu = mkEnableOption "";
                      series = mkEnableOption "";
                      etc = mkEnableOption "";
                      h = mkEnableOption "";
                    };
                  };
                  default = {
                    animu = false;
                    series = false;
                    etc = false;
                    h = false;
                  };
                };

                # An extra list of directories that is bound to the container.
                inherit (containerOptions) bindMounts;

                config = mkOption {
                  description = ''
                    A specification of the desired configuration of this
                    container, as a NixOS module.
                  '';
                  type = types.raw;
                };

                extraModules = mkOption {
                  description = "Extra modules to add to the system.";
                  type = with types; listOf raw;
                  default = [ ];
                };
              };
            }
          )
        );
    };

  config = {
    containers =
      let
        inherit (pkgs.stdenvNoCC) hostPlatform;
        vpnNetCfg = config.my.networking.vpn-gateway;
        networking-hosts = config.networking.hosts;
      in
      flip mapAttrs config.modules.containers (
        name: cfg:
        let
          netCfg = config.my.networking.${name};
          container-base =
            { config, pkgs, ... }:
            let
              containerCfg = config.container;
            in
            {
              imports = with self.nixosModules; [
                common-programs
                groups
                home-network-addrs
                i18n
                home-pki
                server-services
                users
                zsh
                ../../../common/secrets

                ../ports.nix
              ];

              options.container = {
                name = mkOption {
                  type = types.str;
                  description = "The name of the container";
                  default = name;
                };
                nameservers = mkOption {
                  type = types.listOf types.str;
                  description = "The list of nameservers used by the container";
                  default =
                    if cfg.vpn then
                      [
                        "1.1.1.1"
                        "1.0.0.1"
                        "8.8.8.8"
                        "8.8.4.4"
                      ]
                    else
                      [ config.home.addrs.router ];
                };
              };

              config = {
                nixpkgs = {
                  inherit hostPlatform;
                };
                boot.isContainer = true;

                system.stateVersion = "22.11";

                # Base network configs
                networking = {
                  hosts = networking-hosts;
                  useDHCP = mkOverride 900 false;
                  enableIPv6 = mkOverride 900 false;
                  hostName = name;
                  defaultGateway = mkOverride 900 (if cfg.vpn then vpnNetCfg.mainAddr else config.home.addrs.router);
                  useHostResolvConf = false;
                  nameservers = containerCfg.nameservers;
                  interfaces = {
                    mv-enp6s0.ipv4.addresses = [
                      {
                        address = netCfg.mainAddr;
                        prefixLength = 16;
                      }
                    ];
                  };
                  firewall =
                    let
                      getPorts =
                        proto:
                        flatten (map (portDef: portDef.port) (filter (portDef: portDef.protocol == proto) netCfg.ports));
                    in
                    {
                      allowedTCPPorts = getPorts "tcp" ++ getPorts "http";
                      allowedUDPPorts = getPorts "udp";
                    };
                };

                # ACME Settings
                security.acme = {
                  acceptTerms = true; # kinda pointless since we never use upstream
                  defaults = {
                    server = "https://ca.lan/acme/acme/directory";
                    renewInterval = "hourly";
                  };
                };

                # Configure the network setup to
                systemd.services.network-setup.serviceConfig = mkIf cfg.vpn {
                  Restart = "on-failure";
                  RestartSec = "5s";
                  StartLimitIntervalSec = "0";
                };

                # Have manpages
                environment.systemPackages = with pkgs; [
                  man
                  netcat
                  tcpdump
                  htop
                  nmon
                  bat
                ];
              };
            };
        in
        {
          # This can be overriden by just defining it.
          autoStart = mkDefault true;
          privateNetwork = true;
          inherit (cfg)
            enableTun
            ephemeral
            timeoutStartSec
            extraFlags
            ;

          # External LAN
          macvlans = [ "enp6s0" ];

          bindMounts = mkMerge [
            cfg.bindMounts
            (optionalAttrs cfg.builtinMounts.animu {
              "/mnt/animu" = {
                hostPath = "/storage/animu";
                isReadOnly = false;
              };
            })
            (optionalAttrs cfg.builtinMounts.series {
              "/mnt/series" = {
                hostPath = "/storage/series";
                isReadOnly = false;
              };
            })
            (optionalAttrs cfg.builtinMounts.etc {
              "/mnt/etc" = {
                hostPath = "/storage/etc";
                isReadOnly = false;
              };
            })
            (optionalAttrs cfg.builtinMounts.h {
              "/mnt/h" = {
                hostPath = "/storage/h";
                isReadOnly = false;
              };
            })
          ];

          path =
            toString
              (inputs.nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = {
                  inherit system inputs liveCd;
                };
                modules = cfg.extraModules ++ [
                  container-base
                  cfg.config
                ];
              }).config.system.build.toplevel;
        }
      );

    systemd.services =
      let
        containersNeedingVpn = filterAttrs (n: v: v.vpn) config.modules.containers;
        servicesNeedingVpn = flip mapAttrs' containersNeedingVpn (
          name: cfg: {
            name = "container@${name}";
            value = {
              after = mkIf cfg.vpn [ "container@vpn-gateway.service" ];
            };
          }
        );
        needsStepCA = flip mapAttrs' config.modules.containers (
          name: _: {
            name = "containers@${name}";
            value = {
              after = [ "step-ca.service" ];
              requires = [ "step-ca.service" ];
            };
          }
        );
      in
      mkMerge [
        servicesNeedingVpn
        needsStepCA
      ];
  };
}
