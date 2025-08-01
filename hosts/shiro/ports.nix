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

  config.shiro.ports =
    {
      nginx-http = 80;
      nginx-https = 443;

      # Fixed ports: 60000-

      # RESERVED: Games (60000-60999)
    }
    // (
      let
        services = [
          # MinIO
          "minio"
          "minio-console"

          # Monitoring
          "prometheus-lm-sensors-exporter"
          "prometheus-node-exporter"
          "prometheus-smartmontools-exporter"
          "prometheus-zfs-exporter"

          # Downloaders
          "downloader"
          "flood"
          "jackett"
          "live-stream-dvr"
          "qbittorrent-web"
          "sonarr"

          # Entertainment
          "danbooru"
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
