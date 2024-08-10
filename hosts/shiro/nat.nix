{ lib, ... }:
let
  inherit (lib) mkOverride;
in
{
  # Flags to make NAT work in VPN gateway. (hopefully)
  boot.kernelModules = [ "nf_nat_ftp" ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = mkOverride 99 true;
    "net.ipv4.conf.default.forwarding" = mkOverride 99 true;

    # Do not prevent IPv6 autoconfiguration.
    # See <http://strugglers.net/~andy/blog/2011/09/04/linux-ipv6-router-advertisements-and-forwarding/>.
    "net.ipv6.conf.all.accept_ra" = mkOverride 99 2;
    "net.ipv6.conf.default.accept_ra" = mkOverride 99 2;

    # Forward IPv6 packets.
    "net.ipv6.conf.all.forwarding" = mkOverride 99 true;
    "net.ipv6.conf.default.forwarding" = mkOverride 99 true;
  };
}
