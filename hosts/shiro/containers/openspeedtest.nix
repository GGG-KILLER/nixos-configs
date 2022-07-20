{...}: {
  virtualisation.oci-containers.containers.openspeedtest = {
    image = "openspeedtest/latest";
    ports = ["3030:3000"];
  };

  networking.firewall.allowedTCPPorts = [3030];
  networking.firewall.allowedUDPPorts = [3030];
}
