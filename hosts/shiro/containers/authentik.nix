{inputs, ...}: {
  my.networking.sso = {
    mainAddr = "192.168.2.247"; # ipgen -n 192.168.2.0/24 sso
    extraNames = ["sso.shiro"];
    ports = [
      {
        protocol = "http";
        port = 80;
        description = "Local NGINX";
      }
      {
        protocol = "http";
        port = 443;
        description = "Local Nginx";
      }
      {
        protocol = "http";
        port = 9000;
        description = "Authentik";
      }
      {
        protocol = "http";
        port = 9443;
        description = "Authentik";
      }
    ];
  };

  systemd.services."container@sso.service".requires = ["container@pgsql-prd.service"];
  systemd.services."container@sso.service".after = ["container@pgsql-prd.service"];

  modules.containers.sso = {
    ephemeral = false;
    timeoutStartSec = "2min";

    bindMounts = {
      "/secrets" = {
        hostPath = "/run/container-secrets/sso";
        isReadOnly = true;
      };
    };

    extraModules = [inputs.authentik-nix.nixosModules.default];

    config = {
      lib,
      config,
      ...
    }: {
      # https://goauthentik.io/docs/installation/docker-compose#explanation
      # RANT: The only freaking reason I need a whole fucking container for a single fucking app.
      time.timeZone = lib.mkForce "UTC";

      services.authentik = {
        enable = true;
        createDatabase = false;
        environmentFile = "/secrets/authentik.env";
        settings = {
          avatars = "initials";
          disable_startup_analytics = true;
          cert_discovery_dir = "/var/lib/acme/";
          log_level = "trace";

          postgresql = {
            host = "pgprd.shiro.lan";
            name = "authentik";
            user = "authentik";
          };
        };
      };

      services.nginx.upstreams.authentik = {
        servers."127.0.0.1:9443" = {};
        extraConfig = ''
          keepalive 10;
        '';
      };

      security.acme.certs."sso.shiro.lan".email = "sso@sso.shiro.lan";
      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;

        virtualHosts."sso.shiro.lan" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "https://localhost:9443";
          };
        };
      };
    };
  };
}
