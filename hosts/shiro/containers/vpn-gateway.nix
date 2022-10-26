{
  config,
  lib,
  ...
} @ args:
with lib; let
  consts = config.my.constants;
  secrets = config.my.secrets.vpn.mullvad;
in {
  my.networking.vpn-gateway = {
    ipAddr = "192.168.1.7";
  };

  modules.containers.vpn-gateway = {
    enableTun = true;

    bindMounts = {
      "/secrets" = {
        hostPath = "/run/container-secrets/vpn-gateway";
        isReadOnly = true;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: let
      wg-interface = "wg-mullvad";
    in {
      # VPN Config
      networking.wg-quick.interfaces.${wg-interface} = let
        iptables = "${pkgs.iptables}/bin/iptables";
        ip6tables = "${pkgs.iptables}/bin/iptables";
        wg = "${pkgs.wireguard-tools}/bin/wg";
      in {
        address = [secrets.address];
        dns = [secrets.dns];
        privateKeyFile = "/secrets/mullvad-privkey";
        # Thanks to https://www.reddit.com/r/WireGuard/comments/gf989b/comment/fqek1t2/ for this killswitch
        postUp = ''
          ${iptables} -N WG_KILLSWITCH
          ${iptables} -A OUTPUT -m mark ! --mark $(${wg} show ${wg-interface} fwmark) -m addrtype ! --dst-type LOCAL -j WG_KILLSWITCH
          ${iptables} -A WG_KILLSWITCH -o ${wg-interface} -j RETURN
          ${iptables} -A WG_KILLSWITCH -o mv-enp6s0 -m iprange --dst-range 192.168.1.2-192.168.1.100 -j RETURN
          ${iptables} -A WG_KILLSWITCH -j REJECT
        '';
        preDown = ''
          ${iptables} -D OUTPUT -m mark ! --mark $(${wg} show ${wg-interface} fwmark) -m addrtype ! --dst-type LOCAL -j WG_KILLSWITCH
          ${iptables} -X WG_KILLSWITCH
        '';
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
        internalIPs = ["192.168.1.0/24"];
        externalInterface = wg-interface;
      };

      # Watchdog
      systemd.services.wireguard-watchdog = {
        description = "Service to fix wireguard if it's not working.";
        after = ["wg-quick-${wg-interface}.service"];
        partOf = ["wg-quick-${wg-interface}.service"];
        startAt = "*:0,15,30,45";
        path = with pkgs; [iproute2 curl systemd];
        script = ''
          #! ${pkgs.bash}/bin/bash
          set -euo pipefail

          if ! curl https://f.ggg.dev/azenv ; then
            echo "Restarting wireguard..."
            ip link del ${wg-interface}
            systemctl restart wg-quick-${wg-interface}.service
          fi
        '';
        serviceConfig.Type = "oneshot";
      };
    };
  };
}
