{
  config,
  pkgs,
  ...
}: let
  zigbee2mqtt = {
    lib,
    buildNpmPackage,
    fetchFromGitHub,
    systemdMinimal,
    nixosTests,
    nix-update-script,
  }:
    buildNpmPackage rec {
      pname = "zigbee2mqtt";
      version = "1.36.1";

      src = fetchFromGitHub {
        owner = "Koenkk";
        repo = "zigbee2mqtt";
        rev = version;
        hash = "sha256-LZ25EWO4cOVnF0bWFKwGfnX7kpzNafp1X6+/JYxn6Ek=";
      };

      npmDepsHash = "sha256-6EorAqPLusWAEfTePn+O+tgZcv3g82mkPs2hSHPRRfo=";

      buildInputs = [
        systemdMinimal
      ];

      passthru.tests.zigbee2mqtt = nixosTests.zigbee2mqtt;
      passthru.updateScript = nix-update-script {};

      meta = with lib; {
        changelog = "https://github.com/Koenkk/zigbee2mqtt/releases/tag/${version}";
        description = "Zigbee to MQTT bridge using zigbee-shepherd";
        homepage = "https://github.com/Koenkk/zigbee2mqtt";
        license = licenses.gpl3;
        longDescription = ''
          Allows you to use your Zigbee devices without the vendor's bridge or gateway.

          It bridges events and allows you to control your Zigbee devices via MQTT.
          In this way you can integrate your Zigbee devices with whatever smart home infrastructure you are using.
        '';
        maintainers = with maintainers; [sweber hexa];
        platforms = platforms.linux;
        mainProgram = "zigbee2mqtt";
      };
    };
in {
  # For debugging
  environment.systemPackages = with pkgs; [zigpy-cli];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", SYMLINK+="sonoff_zigbee", MODE="0660", GROUP="zigbee2mqtt"
  '';

  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.callPackage zigbee2mqtt {};
    dataDir = "/zfs-main-pool/data/zigbee2mqtt";
    settings = {
      homeassistant = true;
      availability = true;
      permit_join = false;
      serial.port = "/dev/sonoff_zigbee";

      mqtt.server = "mqtt://127.0.0.1:${toString config.shiro.ports.mqtt}";
      mqtt.version = 5;

      frontend = {
        port = config.shiro.ports.zigbee2mqtt;
        host = "127.0.0.1";
        url = "https://z2m.hass.lan";
      };

      external_converters = ["TS0601_TZE200_lawxy9e2.js"];
    };
  };
  systemd.services."zigbee2mqtt.service".requires = ["docker-mqtt-hass.service" "home-assistant.service"];
  systemd.services."zigbee2mqtt.service".after = ["docker-mqtt-hass.service" "home-assistant.service"];

  virtualisation.oci-containers.containers.mqtt-hass = {
    image = "eclipse-mosquitto:2.0";
    volumes = [
      "/zfs-main-pool/data/mosquitto:/mosquitto"
    ];
    ports = [
      "${toString config.shiro.ports.mqtt}:1883"
      "${toString config.shiro.ports.mqtt-idk}:9001"
    ];
    cmd = ["mosquitto" "-c" "/mosquitto-no-auth.conf"];
    extraOptions = [
      "--ipc=none"
    ];
  };

  services.home-assistant = {
    enable = true;
    configDir = "/zfs-main-pool/data/home-assistant";
    configWritable = true;

    extraComponents = ["default_config" "mqtt" "met"];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      zigbee2mqtt-networkmap
      mini-graph-card
    ];

    config = {
      default_config = {};
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
        server_host = ["127.0.0.1"];
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
