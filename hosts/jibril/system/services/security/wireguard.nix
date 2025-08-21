{ config, ... }:
{
  # enable NAT
  networking.nat.enable = true;
  networking.nat.enableIPv6 = true;
  networking.nat.externalInterface = "enp0s31f6";
  networking.nat.internalInterfaces = [ "wglan" ];
  networking.nat.internalIPs = [ "192.168.5.1/24" ];
  networking.nat.internalIPv6s = [ "fdc9:281f:04d7:9ee9::1/64" ];

  # Public key: 3FNvV2MhtG1ux/vSG+TW3y0Ebenm3qEtQjKZveAMSX0=
  networking.wg-quick.interfaces.wglan = {
    address = [
      "192.168.5.1/24"
      "fdc9:281f:04d7:9ee9::1/64"
    ];
    listenPort = config.jibril.ports.wireguard;
    privateKeyFile = config.age.secrets.wireguard-key.path;

    # Phone Addr:  192.168.5.3/32 fdc9:281f:04d7:9ee9::3/128
    # Coffee:      192.168.5.4/32 fdc9:281f:04d7:9ee9::4/128
    # Coffee 2:    192.168.5.5/32 fdc9:281f:04d7:9ee9::5/128
    # Night:       192.168.5.6/32 fdc9:281f:04d7:9ee9::6/128
    peers = [
      # Phone
      {
        publicKey = "d0YNPnEEs3sIphrnuWEjDMqjqAPlL8xvIaygTJQ1Y08=";
        presharedKeyFile = config.age.secrets.wireguard-phone-psk.path;
        allowedIPs = [
          "192.168.5.3/32"
          "fdc9:281f:04d7:9ee9::3/128"
        ];
      }
      # Coffee
      {
        publicKey = "zj6VD5GT50+yXMFgYoiDEzkKWBOnFCF9+k8jbQ4uhi8=";
        presharedKeyFile = config.age.secrets.wireguard-coffee-psk.path;
        allowedIPs = [
          "192.168.5.4/32"
          "fdc9:281f:04d7:9ee9::4/128"
        ];
      }
      # Coffee 2
      {
        publicKey = "NIiYgtDRv0MKXs6tsp3PZuEja7MXrBpNQhNXsFHvm08=";
        presharedKeyFile = config.age.secrets.wireguard-coffee2-psk.path;
        allowedIPs = [
          "192.168.5.5/32"
          "fdc9:281f:04d7:9ee9::5/128"
        ];
      }
      # Night
      {
        publicKey = "aqGZBpyD7/NZtcbBMq57t91PO5aAvYFnz7Pux0HAhhM=";
        presharedKeyFile = config.age.secrets.wireguard-night-psk.path;
        allowedIPs = [
          "192.168.5.6/32"
          "fdc9:281f:04d7:9ee9::6/128"
        ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ config.jibril.ports.wireguard ];
}
