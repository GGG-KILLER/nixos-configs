{
  self,
  system,
  config,
  ...
}:
let
  z2mDataDir = "/var/lib/zigbee2mqtt";
  hassDataDir = "/var/lib/home-assistant";
in
{
  jibril.dynamic-ports = [
    "zigbee2mqtt"
    "home-assistant"
  ];

  # For debugging
  # environment.systemPackages = with pkgs; [ zigpy-cli ];

  virtualisation.oci-containers.networks.home-assistant = { };

  users.users.z2m = {
    uid = 417;
    isSystemUser = true;
    createHome = true;
    home = z2mDataDir;
    group = "z2m";
  };

  users.groups.z2m = {
    gid = 417;
  };

  virtualisation.oci-containers.containers.hass-z2m = rec {
    imageFile = self.packages.${system}.docker-images."ghcr.io/koenkk/zigbee2mqtt:latest";
    image = imageFile.destNameTag;
    dependsOn = [ "hass-mqtt" ];
    user = "${toString config.users.users.z2m.uid}:${toString config.users.groups.z2m.gid}";
    networks = [ "home-assistant" ];
    ports = [ "127.0.0.1:${toString config.jibril.ports.zigbee2mqtt}:8080" ];
    devices = [
      "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20240123134753-if00:/dev/ttyACM0"
    ];
    volumes = [
      "${z2mDataDir}:/app/data"
      "/run/udev:/run/udev:ro"
    ];
    environment = {
      TZ = config.time.timeZone;

      Z2M_ONBOARD_NO_REDIRECT = "1";

      ZIGBEE2MQTT_CONFIG_MQTT_BASE_TOPIC = "zigbee2mqtt";
      ZIGBEE2MQTT_CONFIG_MQTT_SERVER = "mqtt://hass-mqtt:1883";
      ZIGBEE2MQTT_CONFIG_MQTT_VERSION = "5";

      ZIGBEE2MQTT_CONFIG_SERIAL_PORT = "/dev/ttyACM0";
      ZIGBEE2MQTT_CONFIG_SERIAL_ADAPTER = "ember";

      ZIGBEE2MQTT_CONFIG_FRONTEND_ENABLED = "true";
      ZIGBEE2MQTT_CONFIG_FRONTEND_URL = "https://z2m.hass.lan";

      ZIGBEE2MQTT_CONFIG_HOMEASSISTANT_ENABLED = "true";
    };
    extraOptions = [
      "--group-add=27"
      "--ipc=none"
    ];
  };

  virtualisation.oci-containers.containers.hass-mqtt = rec {
    imageFile = self.packages.${system}.docker-images."eclipse-mosquitto:2.1-alpine";
    image = imageFile.destNameTag;
    networks = [ "home-assistant" ];
    volumes = [ "/var/lib/mosquitto:/mosquitto" ];
    cmd = [
      "mosquitto"
      "-c"
      "/mosquitto-no-auth.conf"
    ];
    extraOptions = [ "--ipc=none" ];
  };

  virtualisation.oci-containers.containers.hass = rec {
    imageFile = self.packages.${system}.docker-images."ghcr.io/home-assistant/home-assistant:stable";
    image = imageFile.destNameTag;
    dependsOn = [ "hass-mqtt" ];
    networks = [ "home-assistant" ];
    # ports = [ "127.0.0.1:${toString config.jibril.ports.home-assistant}:8123" ];
    ports = [ "${toString config.jibril.ports.home-assistant}:8123" ];
    volumes = [ "${hassDataDir}:/config" ];
    environment = {
      TZ = config.time.timeZone;
    };
    extraOptions = [ "--ipc=none" ];
  };

  # TODO: Remove once setup is done
  networking.firewall.allowedTCPPorts = [ config.jibril.ports.home-assistant ];

  services.caddy.virtualHosts = {
    "hass.lan".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.jibril.ports.home-assistant}
    '';
    "z2m.hass.lan".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.jibril.ports.zigbee2mqtt}
    '';
  };
}
