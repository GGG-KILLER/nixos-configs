{ config, pkgs, ... }:

let
  port = 61253;
  inp-interface = "wgvpn-proxy";
  out-interface = "ens3";
in
{
  # Enable NAT
  networking.nat = {
    enable = true;
    externalInterface = out-interface;
    internalInterfaces = [ inp-interface ];
  };

  # Configure Wireguard Interface
  networking.wg-quick.interfaces.${inp-interface} =
    let
      iptables = "${pkgs.iptables}/bin/iptables";
    in
    {
      address = [
        "192.168.6.1/24"
        "192.168.7.1/24"
        "192.168.8.1/24"
      ];
      dns = [
        "127.0.0.1"
      ];
      listenPort = port;
      # Public key: aYbxhwwjdrU9YtvU6o1aWtV63iLL0lBlfh+RlRR4LVI=
      privateKey = config.my.secrets.wgvpn-proxy.privateKey;
      postUp = ''
        ${iptables} -A FORWARD -i ${inp-interface} -j ACCEPT
        ${iptables} -t nat -A POSTROUTING -s 192.168.6.0/24 -o ${out-interface} -j MASQUERADE
      '';
      postDown = ''
        ${iptables} -D FORWARD -i ${inp-interface} -j ACCEPT
        ${iptables} -t nat -D POSTROUTING -s 192.168.6.0/24 -o ${out-interface} -j MASQUERADE
      '';
      # Wing:     192.168.6.2/24
      # GGG:      192.168.7.2/24
      # Spar iOS: 192.168.8.2/24
      # Spar PC1: 192.168.8.3/24
      peers = [
        # Wing
        {
          publicKey = "ndEMfoPCV1g5rveRbQp/BAD3cXxtCvi4qlKvV1M9FjI=";
          presharedKey = config.my.secrets.wgvpn-proxy.presharedKeys.wing;
          allowedIPs = [ "192.168.6.0/24" ];
        }
        # GGG
        {
          publicKey = "9e5veN+MDglv9wriGPbSXXZ73T6CI8W+voullqOSuiY=";
          presharedKey = config.my.secrets.wgvpn-proxy.presharedKeys.ggg;
          allowedIPs = [ "192.168.7.0/24" ];
        }
        # Spar iOS
        {
          publicKey = "rrmxFmEhFy0SxDIq2/kTouHPUBjXIvrweDlk9HvMuR0=";
          presharedKey = config.my.secrets.wgvpn-proxy.presharedKeys.spar-ios;
          allowedIPs = [ "192.168.8.0/24" ];
        }
        # Spar PC1
        {
          publicKey = "TQtHm4nt3tWg71tfCAwZsTrbc+Rk89VJkjos8V6pUUE=";
          presharedKey = config.my.secrets.wgvpn-proxy.presharedKeys.spar-pc1;
          allowedIPs = [ "192.168.8.0/24" ];
        }
      ];
    };

  # Enable DNS Server
  services.dnsmasq = {
    enable = true;
    servers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    extraConfig = ''
      interface=${inp-interface}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 53 port ];
  networking.firewall.allowedUDPPorts = [ 53 port ];
}
