{config, ...}: {
  virtualisation.oci-containers.containers.pufferpanel = {
    image = "pufferpanel/pufferpanel:latest";
    ports = [
      "${toString config.shiro.ports.pufferpanel}:8080"
      "${toString config.shiro.ports.pufferpanel-sftp}:5657"
    ];
    environment = {
      PUFFER_DAEMON_CONSOLE_BUFFER = "1000";
      PUFFER_PANEL_REGISTRATIONENABLED = "false";
    };
    volumes = [
      "/zfs-main-pool/data/pufferpanel/etc:/etc/pufferpanel"
      "/zfs-main-pool/data/pufferpanel/var:/var/lib/pufferpanel"
      "/var/run/docker.sock:/var/run/docker.sock"
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--pull=always"
    ];
  };

  modules.services.nginx = {
    virtualHosts."game.shiro.lan" = {
      ssl = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.pufferpanel}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Nginx-Proxy true;
        '';
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [config.shiro.ports.pufferpanel-sftp];
    allowedTCPPortRanges = [
      {
        from = 60000;
        to = 60999;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 60000;
        to = 60999;
      }
    ];
  };
}
