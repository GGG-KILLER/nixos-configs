{ pkgs, config, ... }:
{
  services.dockerRegistry = {
    enable = true;
    enableDelete = true;
    enableGarbageCollect = true;
    listenAddress = "shiro.lan";
    port = config.shiro.ports.docker-registry;
  };

  networking.firewall.allowedTCPPorts = [ config.shiro.ports.docker-registry ];
  networking.firewall.allowedUDPPorts = [ config.shiro.ports.docker-registry ];

  virtualisation.oci-containers.containers.docker-registry-browser = {
    # nix run nixpkgs#nix-prefetch-docker -- --image-name klausmeyer/docker-registry-browser --arch amd64 --os linux --quiet
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "klausmeyer/docker-registry-browser";
      imageDigest = "sha256:e409aa916bbcd03800f518918f821fa3ebd4c19baf74bbdc1d17d1fccf313fcc";
      hash = "sha256-pM7jgz3+6wkAK3+jVn/AcjpSCpr0Vt0fzn8C0UnWjjM=";
      finalImageName = "klausmeyer/docker-registry-browser";
      finalImageTag = "latest";
    };
    image = "klausmeyer/docker-registry-browser:latest";
    ports = [ "${toString config.shiro.ports.docker-registry-browser}:8080" ];
    environment = {
      ENABLE_COLLAPSE_NAMESPACES = "true";
      ENABLE_DELETE_IMAGES = "true";
      DOCKER_REGISTRY_URL = "http://shiro.lan:${toString config.shiro.ports.docker-registry}";
      PUBLIC_REGISTRY_URL = "docker.lan";
      SECRET_KEY_BASE = config.my.secrets.docker-registry-browser.secret-key-base;
    };
    extraOptions = [
      "--cap-drop=ALL"
      "--dns=192.168.1.1"
      "--ipc=none"
    ];
  };

  modules.services.nginx.clientMaxBodySize = "0";
  modules.services.nginx.virtualHosts."docker.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.shiro.ports.docker-registry-browser}";
      recommendedProxySettings = true;
    };
    locations."/v2/" = {
      proxyPass = "http://shiro.lan:${toString config.shiro.ports.docker-registry}";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
        client_max_body_size 0;
      '';
    };
  };
}
