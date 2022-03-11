{ ... }:

let
  port = 17606;
in
{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ port ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ port ];
  networking.firewall.allowedUDPPorts = [ port ];
}
