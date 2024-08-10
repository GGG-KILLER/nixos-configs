{ config, ... }:
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
    image = "klausmeyer/docker-registry-browser";
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
      "--pull=always"
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
