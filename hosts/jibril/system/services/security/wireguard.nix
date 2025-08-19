{ config, ... }:
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;
  networking.interfaces.wglan.proxyARP = true;

  networking.wg-quick.interfaces.wglan = {
    address = [ "192.168.5.1/32" ];
    dns = [ "192.168.2.2" ];
    listenPort = config.jibril.ports.wireguard;
    # Public key: 3FNvV2MhtG1ux/vSG+TW3y0Ebenm3qEtQjKZveAMSX0=
    privateKeyFile = config.age.secrets.wireguard-key.path;
    # Phone Addr:  192.168.5.3/32
    # Coffee:      192.168.5.4/32
    # Coffee 2:    192.168.5.5/32
    # Night:       192.168.5.6/32
    peers = [
      # Phone
      {
        publicKey = "d0YNPnEEs3sIphrnuWEjDMqjqAPlL8xvIaygTJQ1Y08=";
        presharedKeyFile = config.age.secrets.wireguard-phone-psk.path;
        allowedIPs = [ "192.168.5.3/32" ];
      }
      # Coffee
      {
        publicKey = "zj6VD5GT50+yXMFgYoiDEzkKWBOnFCF9+k8jbQ4uhi8=";
        presharedKeyFile = config.age.secrets.wireguard-coffee-psk.path;
        allowedIPs = [ "192.168.5.4/32" ];
      }
      # Coffee 2
      {
        publicKey = "NIiYgtDRv0MKXs6tsp3PZuEja7MXrBpNQhNXsFHvm08=";
        presharedKeyFile = config.age.secrets.wireguard-coffee2-psk.path;
        allowedIPs = [ "192.168.5.5/32" ];
      }
      # Night
      {
        publicKey = "aqGZBpyD7/NZtcbBMq57t91PO5aAvYFnz7Pux0HAhhM=";
        presharedKeyFile = config.age.secrets.wireguard-night-psk.path;
        allowedIPs = [ "192.168.5.6/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ config.jibril.ports.wireguard ];
}
