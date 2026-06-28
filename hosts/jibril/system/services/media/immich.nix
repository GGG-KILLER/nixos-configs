{ config, ... }: {
  jibril.dynamic-ports = [ "immich" ];

  services.immich.enable = true;
  services.immich.host = "127.0.0.1";
  services.immich.port = config.jibril.ports.immich;

  services.immich.accelerationDevices = [ "/dev/dri/renderD128" ];

  services.immich.settings = null; # Allow config from UI
  services.immich.environment.IMMICH_LOG_LEVEL = "warn";
  services.immich.environment.IMMICH_TRUSTED_PROXIES = "127.0.0.1";

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  services.caddy.virtualHosts."fotos.lan".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString config.jibril.ports.immich}
  '';
}
