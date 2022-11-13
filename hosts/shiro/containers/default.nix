{
  system,
  inputs,
  options,
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./downloader.nix
    ./firefly-iii.nix
    ./home-assistant.nix
    ./jellyfin.nix
    ./network-share.nix
    ./openspeedtest.nix
    ./pgsql.nix
    #./pz-server.nix
    ./qbittorrent.nix
    ./sonarr.nix
    ./vpn-gateway.nix
  ];

  options.modules.containers = let
    containerOptions = options.containers.type.getSubOptions [];
  in
    mkOption {
      type = with types;
        attrsOf (submodule ({name, ...}: {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
            };

            vpn = mkEnableOption "whether this container should be tunneled through the VPN";
            enableTun = containerOptions.enableTun;
            ephemeral = mkOption {
              type = containerOptions.ephemeral.type;
              description = containerOptions.ephemeral.description;
              default = true;
            };
            timeoutStartSec = containerOptions.timeoutStartSec;

            builtinMounts = mkOption {
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
            bindMounts = containerOptions.bindMounts;

            config = mkOption {
              description = ''
                A specification of the desired configuration of this
                container, as a NixOS module.
              '';
              type = types.raw;
            };
          };
        }));
    };

  config = {
    containers = let
      inherit (config.nixpkgs) localSystem;
      consts = config.my.constants;
      vpnNetCfg = config.my.networking.vpn-gateway;
      networking-hosts = config.networking.hosts;
    in
      flip mapAttrs config.modules.containers (name: cfg: let
        netCfg = config.my.networking.${name};
        container-base = {
          config,
          pkgs,
          ...
        }: let
          containerCfg = config.container;
        in {
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
                if cfg.vpn
                then consts.networking.vpnNameservers
                else ["192.168.1.1"];
            };
          };

          config = {
            nixpkgs = {inherit localSystem;};
            boot.isContainer = true;

            system.stateVersion = "22.11";

            # Enable X11 Libs
            environment.noXlibs = false;

            # Base network configs
            networking = {
              hosts = networking-hosts;
              useDHCP = mkOverride 900 false;
              enableIPv6 = mkOverride 900 false;
              hostName = name;
              defaultGateway = mkOverride 900 (
                if cfg.vpn
                then vpnNetCfg.ipAddr
                else "192.168.1.1"
              );
              useHostResolvConf = false;
              nameservers = containerCfg.nameservers;
              interfaces = {
                mv-enp6s0.ipv4.addresses = [
                  {
                    address = netCfg.mainAddr;
                    prefixLength = 24;
                  }
                ];
              };
              firewall = let
                getPorts = proto:
                  flatten (map (portDef: portDef.port) (filter (portDef: portDef.protocol == proto) netCfg.ports));
              in {
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

            # Enable the OpenSSH server.
            services.sshd.enable = true;

            # Have manpages
            environment.systemPackages = with pkgs; [man git netcat tcpdump htop nmon];
          };
        };
      in {
        # This can be overriden by just defining it.
        autoStart = mkDefault true;
        privateNetwork = true;
        inherit (cfg) enableTun ephemeral timeoutStartSec;

        # External LAN
        macvlans = ["enp6s0"];

        bindMounts = mkMerge [
          cfg.bindMounts
          (optionalAttrs cfg.builtinMounts.animu {
            "/mnt/animu" = {
              hostPath = "/zfs-main-pool/data/animu";
              isReadOnly = false;
            };
          })
          (optionalAttrs cfg.builtinMounts.series {
            "/mnt/series" = {
              hostPath = "/zfs-main-pool/data/series";
              isReadOnly = false;
            };
          })
          (optionalAttrs cfg.builtinMounts.etc {
            "/mnt/etc" = {
              hostPath = "/zfs-main-pool/data/etc";
              isReadOnly = false;
            };
          })
          (optionalAttrs cfg.builtinMounts.h {
            "/mnt/h" = {
              hostPath = "/zfs-main-pool/data/h";
              isReadOnly = false;
            };
          })
        ];

        path =
          toString
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit system inputs;
            };
            modules = [
              ../../../common
              container-base
              cfg.config
            ];
          })
          .config
          .system
          .build
          .toplevel;
      });

    systemd.services = let
      containersNeedingVpn = filterAttrs (n: v: v.vpn) config.modules.containers;
      servicesNeedingVpn =
        flip mapAttrs' containersNeedingVpn
        (name: cfg: {
          name = "container@${name}";
          value = {
            after = mkIf cfg.vpn ["container@vpn-gateway.service"];
          };
        });
      needsStepCA =
        flip mapAttrs' config.modules.containers
        (name: _: {
          name = "containers@${name}";
          value = {
            after = ["step-ca.service"];
            requires = ["step-ca.service"];
          };
        });
    in
      mkMerge [
        servicesNeedingVpn
        needsStepCA
        {
          "container@vpn-gateway".wantedBy = map (name: "container@${name}.service") (attrNames containersNeedingVpn);
        }
      ];
  };
}
