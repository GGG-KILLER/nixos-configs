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
    email = mkOption {
      type = with lib.types; nullOr str;
      default = "caddy@${config.networking.fqdn}";
    };
    acme-url = mkOption {
      type = with lib.types; nullOr str;
      default = "https://ca.lan/acme/home/directory";
    };
  };

  config = mkIf cfg.enable {
    services.caddy.enable = true;
    services.caddy.email = cfg.email;
    services.caddy.acmeCA = cfg.acme-url;
    services.caddy.package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/greenpau/caddy-security@v1.1.31"
      ];
      hash = "sha256-aM5UdzmqOwGcdQUzDAEEP30CC1W2UPD10QhF0i7GwQE=";
    };

    # https://caddyserver.com/docs/caddyfile/options
    services.caddy.globalConfig = ''
      # General Options
      grace_period 10s
      metrics {
        per_host
      }

      # TLS Options
      skip_install_trust
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
