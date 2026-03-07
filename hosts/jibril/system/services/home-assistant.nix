{
  self,
  system,
  config,
  lib,
  ...
}:
{
  jibril.dynamic-ports = [
    "zigbee2mqtt"
    "home-assistant"
  ];

  # For debugging
  # environment.systemPackages = with pkgs; [ zigpy-cli ];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", SYMLINK+="sonoff_zigbee", MODE="0660", GROUP="zigbee2mqtt"
  '';

  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/var/lib/zigbee2mqtt";
    settings = {
      homeassistant.enable = true;
      availability = true;
      permit_join = false;
      serial.port = "/dev/sonoff_zigbee";
      serial.adapter = "ember";

      mqtt.server = "mqtt://127.0.0.1:${toString config.jibril.ports.mqtt}";
      mqtt.version = 5;

      frontend = {
        port = config.jibril.ports.zigbee2mqtt;
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
    imageFile = self.packages.${system}.docker-images."eclipse-mosquitto:2.0";
    image = imageFile.destNameTag;
    volumes = [ "/var/lib/mosquitto:/mosquitto" ];
    ports = [
      "${toString config.jibril.ports.mqtt}:1883"
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
      "alert"
      "androidtv_remote"
      "application_credentials"
      "automation"
      "backblaze_b2"
      "calendar"
      "command_line"
      "counter"
      "device_automation"
      "dhcp"
      "diagnostics"
      "discord"
      "esphome"
      "filter"
      "flux"
      "group"
      "history_stats"
      "history"
      "holiday"
      "input_boolean"
      "input_button"
      "input_datetime"
      "input_number"
      "input_select"
      "input_text"
      "local_calendar"
      "local_todo"
      "met"
      "mqtt"
      "ping"
      "rest_command"
      "rest"
      "schedule"
      "script"
      "shell_command"
      "template"
      "threshold"
      "timer"
      "uptime"
      "utility_meter"
      "workday"
      "zha"
      "zone"
    ];

    config = {
      default_config = { };
      # HTTP confs
      http = {
        server_port = config.jibril.ports.home-assistant;
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      # Enable the frontend
      frontend = { };
      mobile_app = { };
    };
  };

  services.caddy.virtualHosts = {
    "hass.lan".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.jibril.ports.home-assistant}
    '';
    "z2m.hass.lan".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.jibril.ports.zigbee2mqtt}
    '';
  };
}
