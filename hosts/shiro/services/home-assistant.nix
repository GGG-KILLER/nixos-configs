{
  config,
  pkgs,
  ...
}: {
  # For debugging
  environment.systemPackages = with pkgs; [zigpy-cli];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", SYMLINK+="sonoff_zigbee", MODE="0660", GROUP="zigbee2mqtt"
  '';

  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/zfs-main-pool/data/zigbee2mqtt";
    settings = {
      homeassistant = true;
      availability = true;
      permit_join = false;
      serial.port = "/dev/sonoff_zigbee";

      mqtt.server = "mqtt://127.0.0.1";

      frontend = {
        port = config.shiro.ports.zigbee2mqtt;
        url = "https://z2m.hass.lan";
      };
    };
  };
  systemd.services."zigbee2mqtt.service".requires = ["mosquitto.service" "home-assistant.service"];
  systemd.services."zigbee2mqtt.service".after = ["mosquitto.service" "home-assistant.service"];

  services.mosquitto = {
    enable = true;
    dataDir = "/zfs-main-pool/data/mosquitto";
    listeners = [
      {
        address = "127.0.0.1";
        port = config.shiro.ports.mqtt;
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
    configDir = "/zfs-main-pool/data/home-assistant";
    configWritable = true;
    config = {
      default_config = {};
      # HTTP confs
      http = {
        server_port = config.shiro.ports.home-assistant;
        trusted_proxies = ["127.0.0.1"];
        use_x_forwarded_for = true;
      };
      # Enable the frontend
      frontend = {};
      mobile_app = {};
    };
  };

  modules.services.nginx = {
    virtualHosts."hass.lan" = {
      ssl = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.home-assistant}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };
    virtualHosts."z2m.hass.lan" = {
      ssl = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.zigbee2mqtt}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };
  };
}
