{
  self,
  system,
  config,
  ...
}:
{
  jibril.dynamic-ports = [
    "docker-registry"
    "docker-registry-browser"
  ];

  services.dockerRegistry = {
    enable = true;
    enableDelete = true;
    enableGarbageCollect = true;
    listenAddress = "127.0.0.1";
    port = config.jibril.ports.docker-registry;
  };

  networking.firewall.allowedTCPPorts = [ config.jibril.ports.docker-registry ];
  networking.firewall.allowedUDPPorts = [ config.jibril.ports.docker-registry ];

  virtualisation.oci-containers.containers.docker-registry-browser = rec {
    imageFile = self.packages.${system}.docker-images."klausmeyer/docker-registry-browser:latest";
    image = imageFile.destNameTag;
    ports = [ "${toString config.jibril.ports.docker-registry-browser}:8080" ];
    environment = {
      ENABLE_COLLAPSE_NAMESPACES = "true";
      ENABLE_DELETE_IMAGES = "true";
      DOCKER_REGISTRY_URL = "http://127.0.0.1:${toString config.jibril.ports.docker-registry}";
      PUBLIC_REGISTRY_URL = "docker.lan";
      SECRET_KEY_BASE = config.my.secrets.docker-registry-browser.secret-key-base;
    };
    extraOptions = [
      "--cap-drop=ALL"
      "--ipc=none"
    ];
  };

  modules.services.nginx.clientMaxBodySize = "0";
  modules.services.nginx.virtualHosts."docker.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.jibril.ports.docker-registry-browser}";
      recommendedProxySettings = true;
    };
    locations."/v2/" = {
      proxyPass = "http://127.0.0.1:${toString config.jibril.ports.docker-registry}";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
        client_max_body_size 0;
      '';
    };
  };
}
