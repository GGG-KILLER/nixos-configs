{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe';
in {
  networking.wg-quick.interfaces.wglan = let
    iptables = getExe' pkgs.iptables "iptables";
  in {
    address = [
      "192.168.5.1/24"
    ];
    dns = [
      "192.168.1.1"
    ];
    listenPort = 61235;
    # Public key: 3FNvV2MhtG1ux/vSG+TW3y0Ebenm3qEtQjKZveAMSX0=
    privateKeyFile = config.age.secrets.wireguard-key.path;
    postUp = [
      "${iptables} -A FORWARD -i wglan -j ACCEPT"
      "${iptables} -A FORWARD -o wglan -j ACCEPT"
      "${iptables} -t nat -A POSTROUTING -o mv-enp6s0-host -j MASQUERADE"
    ];
    postDown = [
      "${iptables} -D FORWARD -i wglan -j ACCEPT"
      "${iptables} -D FORWARD -o wglan -j ACCEPT"
      "${iptables} -t nat -D POSTROUTING -o mv-enp6s0-host -j MASQUERADE"
    ];
    # Laptop Addr: 192.168.5.2/24
    # Phone Addr:  192.168.5.3/24
    # Coffee:      192.168.5.4/32
    # Coffee 2:    192.168.5.5/32
    peers = [
      # Laptop
      {
        publicKey = "2BlZhHcZa+/88aonSC1EYly5A3uG2E1Hr5bpxZqs234=";
        presharedKeyFile = config.age.secrets.wireguard-laptop-psk.path;
        allowedIPs = ["192.168.5.2/32"];
      }
      # Phone
      {
        publicKey = "2EqK/0ue4yZ05N8uq9VuDZRgJ3L6wsZXbnoLG9pNa3U=";
        presharedKeyFile = config.age.secrets.wireguard-phone-psk.path;
        allowedIPs = ["192.168.5.3/32"];
      }
      # Coffee
      {
        publicKey = "zj6VD5GT50+yXMFgYoiDEzkKWBOnFCF9+k8jbQ4uhi8=";
        presharedKeyFile = config.age.secrets.wireguard-coffee-psk.path;
        allowedIPs = ["192.168.5.4/32"];
      }
      # Coffee 2
      {
        publicKey = "NIiYgtDRv0MKXs6tsp3PZuEja7MXrBpNQhNXsFHvm08=";
        presharedKeyFile = config.age.secrets.wireguard-coffee2-psk.path;
        allowedIPs = ["192.168.5.5/32"];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [61235];
}
