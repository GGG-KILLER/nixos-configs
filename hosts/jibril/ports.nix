# Port Registry
#
# Here basically are registered all ports used across this server
# including containers and ports only used internally.
{ lib, ... }:
{
  options.jibril.ports = lib.mkOption {
    internal = true;
    description = "Ports of services used in this server.";
    type = with lib.types; attrsOf port;
  };

  config.jibril.ports =
    {
      nginx-http = 80;
      nginx-https = 443;

      postgres = 5432;

      # Fixed ports: 60000-

      # RESERVED: Games (60000-60999)

      # NOTE: Needs to be a fixed port since we can't statically configure this through nix
      mqtt = 61001;

      wireguard = 61235;
    }
    // (
      let
        services = [
          # Security
          "step-ca"
          "kanidm"

          # Docker registry
          "docker-registry"
          "docker-registry-browser"

          # Monitoring
          "grafana"
          "netprobe"
          "prometheus"
          "prometheus-lm-sensors-exporter"
          "prometheus-node-exporter"
          "prometheus-scaphandre-exporter"
          "prometheus-smartmontools-exporter"

          # Smart Home
          "home-assistant"
          "zigbee2mqtt"

          # Misc
          "n8n"
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
