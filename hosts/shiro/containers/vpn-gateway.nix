{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
in
{
  my.networking.vpn-gateway = {
    ipAddrs = {
      elan = "192.168.1.7";
      # clan = "192.168.2.1";
    };
  };

  containers.vpn-gateway = mkContainer {
    name = "vpn-gateway";

    includeAnimu = false;
    includeSeries = false;
    includeEtc = false;
    includeH = false;

    # Let the container create tunnels
    enableTun = true;

    config = { config, pkgs, ... }:
      {
        # VPN Config
        modules.vpn.mullvad = {
          enable = true;
          alwaysRequireVpn = true;
          autoConnect = true;
          emergencyOnFail = true;
          allowLan = true;
          tunnelProtocol = "wireguard";
          location = "br";
          nameservers = consts.networking.vpnNameservers;
        };

        # systemd.services.mullvad-auto-restarter = {
        #   description = "Service to fix mullvad if it's broken.";
        #   after = [ "mullvad.service" ];
        #   startAt = "*:0,15,30,45";
        #   serviceConfig = {
        #     Type = "oneshot";
        #     ExecStart = "+" + (pkgs.writeScript "mullvad_fix" ''
        #       if ! ${pkgs.mullvad-vpn}/bin/mullvad status ; then
        #         echo "Restarting mullvad...";
        #         TALPID_NET_CLS_MOUNT_DIR=/tmp/net_cls timeout 10 ${pkgs.mullvad-vpn}/bin/mullvad-daemon;
        #         systemctl restart mullvad.service;
        #       fi
        #     '');
        #   };
        # };

        # NAT
        networking.nat = {
          enable = true;
          internalIPs = [
            "192.168.1.0/24"
            "192.168.2.0/24"
          ];
          externalInterface = "wg-mullvad";
        };
      };
  };
}
