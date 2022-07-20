{...}: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
  };

  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [80 443];
}
