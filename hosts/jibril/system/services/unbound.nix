{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.unbound.enable = true;
  services.unbound.enableRootTrustAnchor = true;
  services.unbound.resolveLocalQueries = true;
  services.unbound.settings = {
    server = {
      # verbosity = 2;
      interface = [ "0.0.0.0" ];
      access-control = [
        "127.0.0.0/8 allow"
        "192.168.0.0/16 allow"
      ];
      log-time-iso = true;
      hide-identity = true;
      hide-version = true;
      hide-trustanchor = true;
      private-address = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "169.254.0.0/16"
        "fd00::/8"
        "fe80::/10"
        "::ffff:0:0/96"
      ];
      private-domain = [ ''"lan"'' ];
      prefetch = true;
      prefetch-key = true;
      module-config = ''"validator iterator"'';
      unblock-lan-zones = true;
      # local-zone = [ ''"lan." redirect'' ];
      fast-server-permil = 700;
      fast-server-num = 10;
      dns-error-reporting = true;
      use-caps-for-id = true;
      num-threads = 4;

      msg-cache-slabs = 8;
      rrset-cache-slabs = 8;
      infra-cache-slabs = 8;
      key-cache-slabs = 8;
      msg-cache-size = "256m";
      rrset-cache-size = "512m";

      unwanted-reply-threshold = 10000;
    };

    auth-zone = [
      {
        name = "lan.";
        for-downstream = true;
        zonefile = toString (
          let
            reversed-addr = lib.concatStringsSep "." (
              lib.reverseList (lib.splitString "." config.my.networking.jibril.mainAddr)
            );
          in
          pkgs.writeText "lan.zone" ''
            $ORIGIN lan.

            ; Forward zone
            jibril IN A ${config.my.networking.jibril.mainAddr}
            ${lib.concatStringsSep "\n" (
              lib.map (name: "${name} IN CNAME jibril") config.my.networking.jibril.extraNames
            )}

            ; Reverse zone
            ${reversed-addr}.in-addr.arpa. IN PTR jibril.lan.
            ${lib.concatStringsSep "\n" (
              lib.map (
                name: "${reversed-addr}.in-addr.arpa. IN PTR ${name}.lan."
              ) config.my.networking.jibril.extraNames
            )}
          ''
        );
      }
    ];

    forward-zone = [
      {
        name = ".";
        forward-tls-upstream = true;
        forward-addr = [
          "9.9.9.11@853#dns11.quad9.net"
          "149.112.112.11@853#dns11.quad9.net"
          "1.1.1.1@853#cloudflare-dns.com"
          "1.0.0.1@853#cloudflare-dns.com"
          "8.8.8.8@853#dns.google"
          "8.8.4.4@853#dns.google"
        ];
      }
    ];
    remote-control.control-enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    config.jibril.ports.dns
    config.jibril.ports.dns-over-tls
  ];

  networking.firewall.allowedUDPPorts = [
    config.jibril.ports.dns
    config.jibril.ports.dns-over-tls
  ];
}
