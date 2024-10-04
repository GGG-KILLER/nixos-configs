# Port Registry
#
# Here basically are registered all ports used across this server
# including containers and ports only used internally.
{ lib, ... }:
let
  inherit (lib) mkOption mdDoc types;
in
{
  options.shiro.ports = mkOption {
    internal = true;
    description = mdDoc ''
      Ports of services used in the shiro server.
    '';
    type = with types; attrsOf port;
  };

  config.shiro.ports = {
    nginx-http = 80;
    nginx-https = 443;

    docker-registry = 1024;
    docker-registry-browser = 1025;

    minio = 1026;
    minio-console = 1027;

    step-ca = 1028;

    grafana = 1029;
    prometheus = 1030;
    prometheus-lm-sensors-exporter = 1031;
    prometheus-node-exporter = 1032;
    prometheus-smokeping-exporter = 1033;
    prometheus-zfs-exporter = 1034;

    downloader = 1035;

    qbittorrent-web = 1036;
    flood = 1037;

    zigbee2mqtt = 1038;
    home-assistant = 1039;

    homarr = 1040;
    dashdot = 1041;

    statping-ng = 1042;

    netprobe = 1043;

    authentik = 1044;
    authentik-ssl = 1045;

    pufferpanel = 1046;
    pufferpanel-sftp = 1047;

    live-stream-dvr = 1048;

    mqtt = 1883;

    vallheimUDP_A = 2456;
    vallheimUDP_B = 2457;
    vallheimUDP_C = 2458;

    mongo-dev = 27017;
    mongo-prd = 27018;

    sonarr = 8989;

    mqtt-idk = 9001;
    vallheim-control-panel = 9002;

    jackett = 9117;

    # Games: 60000-60999

    wireguard = 61235;
  };
}
