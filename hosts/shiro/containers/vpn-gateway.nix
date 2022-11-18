{
  config,
  lib,
  ...
} @ args:
with lib; let
  secrets = config.my.secrets.vpn.mullvad;
in {
  modules.containers.vpn-gateway = {
    enableTun = true;

    hostBridge = "br-ctlan";
    localAddress = "172.16.0.2/24";

    extraVeths."ctvpn.local" = {
      hostBridge = "br-ctvpn";
      localAddress = "10.11.0.1/10";
    };

    bindMounts = {
      "/secrets" = {
        hostPath = "/run/container-secrets/vpn-gateway";
        isReadOnly = true;
      };
    };

    config = {
      config,
      pkgs,
      lib,
      ...
    }:
      with lib; let
        wg-interface = "wg-mullvad";
      in {
        networking = {
          defaultGateway = "172.16.0.1";
          nameservers = ["10.64.0.1"];
          useHostResolvConf = false;
        };

        # VPN Config
        networking.wg-quick.interfaces.${wg-interface} = {
          address = [secrets.address];
          dns = ["10.64.0.1"];
          privateKeyFile = "/secrets/mullvad-privkey";
          peers = [
            {
              inherit (secrets) endpoint publicKey;
              allowedIPs = ["0.0.0.0/0"];
            }
          ];
        };

        # NAT
        networking.nat = {
          enable = true;
          internalIPs = ["10.0.0.0/8"];
          externalInterface = wg-interface;
        };

        # Forward DNS
        services.dnsmasq = {
          enable = true;
          extraConfig = ''
            listen-address=::1,127.0.0.1,10.11.0.1
          '';
          servers = ["10.64.0.1"];
        };

        networking.firewall.allowedTCPPorts = [53];
        networking.firewall.allowedUDPPorts = [53];

        # Watchdog
        # systemd.services.wireguard-watchdog = {
        #   description = "Service to fix wireguard if it's not working.";
        #   after = ["wg-quick-${wg-interface}.service"];
        #   partOf = ["wg-quick-${wg-interface}.service"];
        #   startAt = "*:0,15,30,45";
        #   path = with pkgs; [iproute2 curl systemd];
        #   script = ''
        #     #! ${pkgs.bash}/bin/bash
        #     set -euo pipefail

        #     if ! curl https://f.ggg.dev/azenv ; then
        #       echo "Restarting wireguard..."
        #       ip link del ${wg-interface}
        #       systemctl restart wg-quick-${wg-interface}.service
        #     fi
        #   '';
        #   serviceConfig.Type = "oneshot";
        # };
      };
  };
}
