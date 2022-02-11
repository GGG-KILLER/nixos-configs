{ lib, ... }:

with lib;
let
  portOptions = {
    options = {
      protocol = mkOption {
        type = types.enum [ "http" "tcp" "udp" ];
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
  networkingOptions = {
    options = {
      name = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "the name of this machine";
      };
      extraNames = mkOption {
        type = with types; listOf str;
        default = [ ];
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
        default = [ ];
        description = "the ports used by the machine";
      };
    };
  };
in
{
  imports = [
    ./hosts.nix
    ./mitmproxy-cert.nix
  ];

  options.my.networking = mkOption {
    type = with types; attrsOf (submodule networkingOptions);
  };

  options.my.constants.networking.vpnNameservers = mkOption {
    type = with types; listOf str;
    default = [ "1.1.1.1" "8.8.8.8" ];
    description = "the nameservers to use when a device is connected to the VPN";
  };

  config = {
    my.networking.shiro = {
      ipAddrs = {
        elan = "192.168.1.2";
        # clan = "192.168.2.7";
      };
    };
  };
}
