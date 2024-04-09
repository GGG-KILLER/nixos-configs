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

  containers.home-assistant.allowedDevices = [
    {
      modifier = "rw";
      node = "/dev/ttyACM0";
    }
  ];

  modules.containers.home-assistant = {
    bindMounts = {
      "/var/lib/hass" = {
        hostPath = "/zfs-main-pool/data/home-assistant";
        isReadOnly = false;
      };
      "/var/lib/zigbee2mqtt" = {
        hostPath = "/zfs-main-pool/data/home-assistant/zigbee2mqtt";
        isReadOnly = false;
      };
      "/var/lib/mosquitto" = {
        hostPath = "/zfs-main-pool/data/home-assistant/mosquitto";
        isReadOnly = false;
      };
      # "/dev/ttyACM0" = {
      #   hostPath = "/dev/ttyACM0";
      #   isReadOnly = false;
      # };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      services.zigbee2mqtt = {
        enable = true;
        settings = {
          advanced.network_key = "GENERATE";
          frontend.port = 45111;
          homeassistant = true;
          mqtt.base_topic = "zigbee2mqtt";
          mqtt.server = "mqtt://localhost";
          permit_join = true;
          serial.port = "/dev/ttyACM0";
        };
      };

      services.mosquitto = {
        enable = true;

        listeners = [
          {
            address = "127.0.0.1";
            port = 1883;
            settings.allow_anonymous = true;
          }
        ];
      };

      services.home-assistant = {
        enable = true;
        package =
          (pkgs.home-assistant.override {
            extraComponents = [
              "default_config"
              "esphome"
              "mqtt"
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
          # Speedtest.net
          speedtestdotnet = {};
        };
      };

      modules.services.nginx = {
        enable = true;
        proxyTimeout = "12h";

        virtualHosts."hass.lan" = {
          ssl = true;

          locations."/" = {
            proxyPass = "http://localhost:8123";
            proxyWebsockets = true;
          };
        };
        virtualHosts."z2m.hass.lan" = {
          ssl = true;

          locations."/" = {
            proxyPass = "http://localhost:45111";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
