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
      verbosity = 2;

      # Listen on all interfaces but only allow local addresses to use this
      interface = [ "0.0.0.0" ];
      access-control = [
        "127.0.0.0/8 allow"
        "192.168.0.0/16 allow"
      ];

      # Allow Unbound to return responses for private IP Addrs
      private-domain = [
        ''"intranet"''
        ''"internal"''
        ''"private"''
        ''"corp"''
        ''"home"''
        ''"lan"''
      ];
      domain-insecure = [
        ''"intranet"''
        ''"internal"''
        ''"private"''
        ''"corp"''
        ''"home"''
        ''"lan"''
      ];
      unblock-lan-zones = true;
      insecure-lan-zones = true;

      # Exclude local subnets from answers
      private-address = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "169.254.0.0/16"
        "fd00::/8"
        "fe80::/10"
        "::ffff:0:0/96"
      ];

      # We use respip to remove IPv6 entries from the responses
      module-config = ''"respip validator iterator"'';
      response-ip = [
        "::/0 redirect"
      ];

      # Allow more recursive queries to upstream DNS servers
      max-global-quota = 300;

      # Wait for a little longer on queries
      discard-timeout = 3800; # in milliseconds

      # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
      harden-glue = true;
      harden-dnssec-stripped = true;
      use-caps-for-id = false;
      prefetch = true; # refresh popular cached entries before they expire
      edns-buffer-size = 1232;

      # Custom settings
      hide-identity = true;
      hide-version = true;
    };

    auth-zone = [
      {
        name = "lan.";
        for-downstream = true;
        zonefile = toString (
          let
            inherit (config.my.networking.jibril) mainAddr;
            padRight =
              width: filler: str:
              let
                strw = lib.stringLength str;
                reqWidth = width - (lib.stringLength filler);
              in
              if strw >= width then str else (padRight reqWidth filler str) + filler;

            hosts = {
              "openwrt.lan" = "192.168.1.1";
              "qbittorrent.lan" = "192.168.2.154";
              "flood.lan" = "192.168.2.154";
              "jellyfin.lan" = "192.168.2.219";
              "vpn-gateway.lan" = "192.168.2.47";
              "jibril.lan" = mainAddr;
            }
            // (lib.listToAttrs (
              lib.map (name: lib.nameValuePair name "192.168.2.133") [
                "shiro.lan"
                "booru.shiro.lan"
                "cp.shiro.lan"
                "downloader.lan"
                "jackett.shiro.lan"
                "mega.shiro.lan"
                "s3.shiro.lan"
                "sonarr.shiro.lan"
              ]
            ))
            // (lib.listToAttrs (
              lib.map (name: lib.nameValuePair "${name}.lan" mainAddr) config.my.networking.jibril.extraNames
            ));

            maxLen = lib.head (
              lib.sort (a: b: a > b) (lib.map (str: lib.stringLength str) (lib.attrNames hosts))
            );
          in
          pkgs.writeText "lan.zone" ''
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: addr: "${padRight (maxLen + 1) " " "${name}."} IN A ${addr}") hosts
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
