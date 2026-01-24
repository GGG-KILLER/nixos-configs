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

  services.caddy.virtualHosts."docker.lan".extraConfig = ''
    reverse_proxy /v2/* http://127.0.0.1:${toString config.jibril.ports.docker-registry}
    reverse_proxy http://127.0.0.1:${toString config.jibril.ports.docker-registry-browser}
  '';
}
