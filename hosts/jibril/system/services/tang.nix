{ config, ... }:
{
  services.tang = {
    enable = true;
    listenStream = [ (toString config.jibril.ports.tang) ];
    # Tang enforces its own systemd-level IP allowlist (IPAddressAllow) —
    # this option has NO default and must be set, independent of the nftables
    # firewall rule below.
    ipAddressAllow = [ "10.0.0.0/16" ]; # home LAN, matches the /16 netmask used elsewhere
  };

  networking.firewall.allowedTCPPorts = [ config.jibril.ports.tang ];
}
