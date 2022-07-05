{ ... }:

{

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
  networking.firewall.allowedUDPPorts = [ 80 ];
}
