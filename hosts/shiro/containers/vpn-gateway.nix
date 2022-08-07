{
  config,
  lib,
  ...
} @ args:
with lib; let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
  secrets = config.my.secrets.vpn.mullvad;
in {
  my.networking.vpn-gateway = {
    ipAddr = "192.168.1.7";
  };

  containers.vpn-gateway = mkContainer {
    name = "vpn-gateway";

    includeAnimu = false;
    includeSeries = false;
    includeEtc = false;
    includeH = false;

    bindMounts = {
      "/secrets" = {
        hostPath = "/run/container-secrets/vpn-gateway";
        isReadOnly = true;
      };
    };

    # Let the container create tunnels
    enableTun = true;

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
        # TODO: Enable kill switch
        # postUp = [
        #   "${iptables} -I OUTPUT ! -o ${wg-interface} -m mark ! --mark $(${wg} show ${wg-interface} fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"
        # ];
        # preDown = [
        #   "${iptables} -D OUTPUT ! -o ${wg-interface} -m mark ! --mark $(${wg} show ${wg-interface} fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"
        # ];
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
    };
  };
}
