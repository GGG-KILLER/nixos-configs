{ lib, config, ... }:
let
  inherit (lib)
    concatStringsSep
    elem
    escapeShellArg
    filterAttrs
    mapAttrs'
    mapAttrsToList
    mkOption
    nameValuePair
    optional
    types
    ;
  inherit (config.virtualisation.oci-containers) backend;
  cfg = config.virtualisation.oci-containers.networks;
in
{
  options.virtualisation.oci-containers.networks = mkOption {
    default = { };
    description = "Docker/Podman networks to create.";
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            serviceName = mkOption {
              type = types.str;
              default = "${backend}-network-${name}";
              defaultText = "<backend>-network-<name>";
              description = "Systemd service name that manages this network.";
            };

            driver = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Driver to manage the network.";
              example = "bridge";
            };

            subnets = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Subnets in CIDR format.";
              example = [ "192.168.100.0/24" ];
            };

            gateways = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "IPv4 or IPv6 gateways for the subnets.";
              example = [ "192.168.100.1" ];
            };

            ipRanges = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Allocate container IPs from sub-ranges (CIDR format).";
              example = [ "192.168.100.128/25" ];
            };

            ipv6 = mkOption {
              type = types.bool;
              default = false;
              description = "Enable IPv6 networking.";
            };

            internal = mkOption {
              type = types.bool;
              default = false;
              description = "Restrict external access to the network.";
            };

            ipamDriver = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "IP Address Management driver.";
              example = "default";
            };

            labels = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Labels to set on the network.";
            };

            driverOptions = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Driver-specific options (passed via --opt).";
            };
          };
        }
      )
    );
  };

  config.systemd.services = mapAttrs' (
    name: netCfg:
    let
      backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";

      createArgs = concatStringsSep " " (
        optional (netCfg.driver != null) "--driver=${escapeShellArg netCfg.driver}"
        ++ map (s: "--subnet=${escapeShellArg s}") netCfg.subnets
        ++ map (g: "--gateway=${escapeShellArg g}") netCfg.gateways
        ++ map (r: "--ip-range=${escapeShellArg r}") netCfg.ipRanges
        ++ optional netCfg.ipv6 "--ipv6"
        ++ optional netCfg.internal "--internal"
        ++ optional (netCfg.ipamDriver != null) "--ipam-driver=${escapeShellArg netCfg.ipamDriver}"
        ++ mapAttrsToList (k: v: "--label=${escapeShellArg "${k}=${v}"}") netCfg.labels
        ++ mapAttrsToList (k: v: "--opt=${escapeShellArg "${k}=${v}"}") netCfg.driverOptions
        ++ [ (escapeShellArg name) ]
      );

      containerServices = mapAttrsToList (_: c: "${c.serviceName}.service") (
        filterAttrs (_: c: elem name c.networks) config.virtualisation.oci-containers.containers
      );
    in
    nameValuePair netCfg.serviceName {
      wantedBy = [ "multi-user.target" ];
      after = lib.optionals (backend == "docker") [
        "docker.service"
        "docker.socket"
      ];
      before = containerServices;
      requiredBy = containerServices;

      serviceConfig = {
        Type = "simple";
        RemainAfterExit = "yes";

        ExecStartPre = "-${backendBin} network rm ${escapeShellArg name}";
        ExecStart = "${backendBin} network create ${createArgs}";
        ExecStop = "${backendBin} network rm ${escapeShellArg name}";
      };
    }
  ) cfg;
}
