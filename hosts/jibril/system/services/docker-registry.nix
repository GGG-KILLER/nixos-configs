{ pkgs, config, ... }:
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
    # nix run nixpkgs#nix-prefetch-docker -- --image-name klausmeyer/docker-registry-browser --arch amd64 --os linux --quiet
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "klausmeyer/docker-registry-browser";
      imageDigest = "sha256:d6fe74a0edf6cb4f421a38170ec6cb5117d13a3aa81ef2f1fbbba771c47fd364";
      hash = "sha256-E0e5ZB/Ol2NRDzkEloceyxoC4ZOoQ22CY/yMUWuXnOI=";
      finalImageName = "klausmeyer/docker-registry-browser";
      finalImageTag = "latest";
    };
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
