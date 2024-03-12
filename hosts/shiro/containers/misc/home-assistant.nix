{lib, ...}: {
  my.networking.home-assistant = {
    mainAddr = "192.168.2.228"; # ipgen -n 192.168.2.0/24 home-assistant
    ports = [
      {
        protocol = "http";
        port = 80;
        description = "Local Nginx";
      }
      {
        protocol = "http";
        port = 443;
        description = "Local Nginx";
      }
    ];
  };

  modules.containers.home-assistant = {
    bindMounts = {
      "/var/lib/hass" = {
        hostPath = "/zfs-main-pool/data/home-assistant";
        isReadOnly = false;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      services.home-assistant = {
        enable = true;
        package =
          (pkgs.home-assistant.override {
            extraComponents = [
              "default_config"
              "esphome"
              "speedtestdotnet"
            ];
          })
          .overrideAttrs (oldAttrs: {
            # Don't run package tests, they take a long time
            doInstallCheck = false;
          });
        configWritable = true;
        config = {
          default_config = {};
          # HTTP confs
          http = {
            trusted_proxies = ["127.0.0.1"];
            use_x_forwarded_for = true;
          };
          # Enable the frontend
          frontend = {};
          mobile_app = {};
          # ESPHome
          esphome = {};
          # Speedtest.net
          speedtestdotnet = {};
        };
      };

      systemd.services.esphome = {
        description = "ESPHome";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          User = "hass";
          Group = "hass";
          Restart = "on-failure";
          WorkingDirectory = config.services.home-assistant.configDir;
          ExecStart = "${lib.getExe pkgs.esphome} dashboard ${config.services.home-assistant.configDir}/esphome";
        };
      };

      security.acme.certs."hass.lan".email = "hass@home-assistant.lan";
      security.acme.certs."esphome.lan".email = "esphome@home-assistant.lan";
      services.nginx = {
        enable = true;

        proxyTimeout = "12h";
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedZstdSettings = true;

        virtualHosts."hass.lan" = {
          enableACME = true;
          addSSL = true;

          locations."/" = {
            proxyPass = "http://localhost:8123";
            proxyWebsockets = true;
          };
        };
        virtualHosts."esphome.lan" = {
          enableACME = true;
          addSSL = true;

          locations."/" = {
            proxyPass = "http://localhost:6052";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
