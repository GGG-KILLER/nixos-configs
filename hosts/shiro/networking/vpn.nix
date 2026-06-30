# Puts the whole host behind the Mullvad WireGuard tunnel.
#
# Full-tunnel egress with a kill switch: everything leaves through `wg-mullvad`
# except traffic to ourselves and to the LAN. The physical `enp6s0` link keeps the
# LAN default route so wg-quick can reach the Mullvad endpoint underneath the tunnel.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe getExe';
  secrets = config.my.secrets.vpn.mullvad;

  wg-interface = "wg-mullvad";

  iptables = getExe' pkgs.iptables "iptables";
  wg = getExe pkgs.wireguard-tools;
  resolvectl = getExe' pkgs.systemd "resolvectl";
in
{
  networking.wg-quick.interfaces.${wg-interface} = {
    address = [ secrets.address ];
    # Sets the tunnel link as the default (`~.`) DNS route in systemd-resolved.
    dns = [ secrets.dns ];
    privateKeyFile = config.age.secrets."mullvad-privkey".path;

    # Kill switch: drop anything that would leave via a non-VPN path, except the
    # tunnel's own encrypted packets, traffic to ourselves, and traffic to the LAN.
    postUp = ''
      ${iptables} -N ${wg-interface}-killswitch
      # WireGuard's own packets carry the interface fwmark and must reach the endpoint.
      ${iptables} -A ${wg-interface}-killswitch -m mark --mark $(${wg} show ${wg-interface} fwmark) -j RETURN
      # Allow traffic to our own addresses and to the LAN (SSH/Caddy/monitoring replies, router DNS).
      ${iptables} -A ${wg-interface}-killswitch -m addrtype --dst-type LOCAL -j RETURN
      ${iptables} -A ${wg-interface}-killswitch -d 10.0.0.0/8 -j RETURN
      # Everything else may only leave through the tunnel.
      ${iptables} -A ${wg-interface}-killswitch ! -o ${wg-interface} -j REJECT
      ${iptables} -I OUTPUT -j ${wg-interface}-killswitch
    '';
    preDown = ''
      ${iptables} -D OUTPUT -j ${wg-interface}-killswitch
      ${iptables} -F ${wg-interface}-killswitch
      ${iptables} -X ${wg-interface}-killswitch
    '';

    peers = [
      {
        inherit (secrets) endpoint publicKey;
        allowedIPs = [ "0.0.0.0/0" ];
      }
    ];
  };

  # Split DNS: `*.lan` is resolved by the LAN router, everything else goes through the
  # tunnel's DNS (set by wg-quick above). Keeps `.lan` resolving even when the VPN is down.
  systemd.services.lan-split-dns = {
    description = "Route .lan DNS queries to the LAN router";
    after = [
      "network-online.target"
      "systemd-resolved.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${resolvectl} dns    enp6s0 ${config.home.addrs.router}
      ${resolvectl} domain enp6s0 '~lan'
    '';
  };
}
