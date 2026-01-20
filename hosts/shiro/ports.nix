# Port Registry
#
# Here basically are registered all ports used across this server
# including containers and ports only used internally.
{ lib, ... }:
{
  options.shiro.ports = lib.mkOption {
    internal = true;
    description = "Ports of services used in this server.";
    type = with lib.types; attrsOf port;
  };

  config.shiro.ports = {
    nginx-http = 80;
    nginx-https = 443;

    # Fixed ports: 60000-

    # RESERVED: Games (60000-60999)

    # External services depend on thse
    prometheus-lm-sensors-exporter = 61001;
    prometheus-node-exporter = 61002;
    prometheus-smartmontools-exporter = 61003;
    prometheus-zfs-exporter = 61004;
  }
  // (
    let
      services = [
        # MinIO
        "minio"
        "minio-console"

        # Downloaders
        "downloader"
        "flood"
        "jackett"
        "live-stream-dvr"
        "qbittorrent-web"
        "sonarr"

        # Entertainment
        "danbooru"

        # File Browser
        "mikochi"
      ];

      inherit (lib)
        listToAttrs
        genList
        elemAt
        length
        ;
    in
    listToAttrs (
      genList (index: {
        name = elemAt services index;
        value = 1024 + index;
      }) (length services)
    )
  );
}
