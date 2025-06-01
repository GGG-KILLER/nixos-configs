{
  config,
  pkgs,
  lib,
  ...
}:
{
  # For debugging
  environment.systemPackages = with pkgs; [ zigpy-cli ];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", SYMLINK+="sonoff_zigbee", MODE="0660", GROUP="zigbee2mqtt"
  '';

  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/var/lib/zigbee2mqtt";
    settings = {
      homeassistant = true;
      availability = true;
      permit_join = false;
      serial.port = "/dev/sonoff_zigbee";
      serial.adapter = "ember";

      mqtt.server = "mqtt://127.0.0.1:${toString config.shiro.ports.mqtt}";
      mqtt.version = 5;

      frontend = {
        port = config.shiro.ports.zigbee2mqtt;
        host = "127.0.0.1";
        url = "https://z2m.hass.lan";
      };

      external_converters = [ "TS0601_TZE200_lawxy9e2.js" ];
    };
  };
  systemd.services.zigbee2mqtt.serviceConfig.Restart = lib.mkForce "always";
  systemd.services.zigbee2mqtt.requires = [
    "docker-mqtt-hass.service"
    "home-assistant.service"
  ];
  systemd.services.zigbee2mqtt.after = [
    "docker-mqtt-hass.service"
    "home-assistant.service"
  ];

  virtualisation.oci-containers.containers.mqtt-hass = rec {
    # nix run nixpkgs#nix-prefetch-docker -- --image-name eclipse-mosquitto --image-tag 2.0 --arch amd64 --os linux --quiet
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "eclipse-mosquitto";
      imageDigest = "sha256:94f5a3d7deafa59fa3440d227ddad558f59d293c612138de841eec61bfa4d353";
      hash = "sha256-bTDUhrhIkxUoeL0SN/8brOLm0L2wlGPJrMalk42KWDU=";
      finalImageName = "eclipse-mosquitto";
      finalImageTag = "2.0";
    };
    image = imageFile.destNameTag;
    volumes = [ "/var/lib/mosquitto:/mosquitto" ];
    ports = [
      "${toString config.shiro.ports.mqtt}:1883"
    ];
    cmd = [
      "mosquitto"
      "-c"
      "/mosquitto-no-auth.conf"
    ];
    extraOptions = [ "--ipc=none" ];
  };

  services.home-assistant = {
    enable = true;
    configDir = "/var/lib/home-assistant";
    configWritable = true;

    extraComponents = [
      "default_config"
      "mqtt"
      "met"
    ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      zigbee2mqtt-networkmap
      mini-graph-card
    ];

    config = {
      default_config = { };
      homeassistant = {
        country = "BR";
        currency = "BRL";
        unit_system = "metric";
        time_zone = "America/Sao_Paulo";
        temperature_unit = "C";
        external_url = "https://hass.lan";
      };
      # HTTP confs
      http = {
        server_host = [ "127.0.0.1" ];
        server_port = config.shiro.ports.home-assistant;
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      # Enable the frontend
      frontend = { };
      mobile_app = { };
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
      locations."^~ /service_worker.js".return = 404;
    };
    virtualHosts."z2m.hass.lan" = {
      ssl = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.zigbee2mqtt}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        sso = true;
      };
    };
  };
}
