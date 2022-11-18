{...}: {
  services.dockerRegistry = {
    enable = true;
    enableDelete = true;
    enableGarbageCollect = true;
    listenAddress = "shiro.lan";
  };

  networking.firewall.allowedTCPPorts = [5000];
  networking.firewall.allowedUDPPorts = [5000];

  virtualisation.oci-containers.containers.docker-registry-browser = {
    image = "klausmeyer/docker-registry-browser";
    ports = ["9001:8080"];
    environment = {
      ENABLE_COLLAPSE_NAMESPACES = "true";
      ENABLE_DELETE_IMAGES = "true";
      DOCKER_REGISTRY_URL = "http://shiro.lan:5000";
      PUBLIC_REGISTRY_URL = "docker.lan";
    };
    extraOptions = [
      "--cap-drop=ALL"
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
    ];
  };

  modules.services.nginx.virtualHosts."docker.lan" = {
    ssl = true;
    locations."/".proxyPass = "http://127.0.0.1:9001";
    locations."/v2/" = {
      proxyPass = "http://shiro.lan:5000";
      extraConfig = ''
        client_max_body_size 0;
      '';
    };
  };
}
