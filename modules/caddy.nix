{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption mkOption;

  cfg = config.ggg.caddy;
in
{
  options.ggg.caddy = {
    enable = mkEnableOption "the pre-configured opinionated Caddy service";
    acme-url = mkOption {
      type = with lib.types; nullOr str;
      default = "https://ca.lan/acme/acme/directory";
    };
  };

  config = mkIf cfg.enable {
    services.caddy.enable = true;
    services.caddy.email = "caddy@${config.networking.hostName}.lan";
    services.caddy.acmeCA = cfg.acme-url;
    services.caddy.package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/greenpau/caddy-security@v1.1.31"
        "github.com/php/frankenphp/caddy@v1.11.1"
        "github.com/dunglas/caddy-cbrotli@v1.0.1" # encode br zstd gzip
      ];
    };

    # https://caddyserver.com/docs/caddyfile/options
    services.caddy.globalConfig = ''
      # General Options
      grace_period 10s
      metrics {
        per_host
      }

      # FrankenPHP (https://frankenphp.dev)
      frankenphp
      order php_server before file_server

      # TLS Options
      skip_install_trust
      key_type ed25519
      cert_lifetime 1h

      # Server Options
      servers {
        listener_wrappers {
          http_redirect
          tls
        }

        strict_sni_host on
      }
    '';

    # HTTP/1 and HTTP/2
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    # HTTP/3
    networking.firewall.allowedUDPPorts = [ 443 ];
  };
}
