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
          disable_startup_analytics = true;
          cert_discovery_dir = "/var/lib/acme/sso.shiro.lan/";
          log_level = "trace";

          postgresql = {
            host = "pgprd.shiro.lan";
            name = "authentik";
            user = "authentik";
          };
        };
      };
      systemd.services.authentik-migrate.serviceConfig = {
        Restart = "on-failure";
        RestartSec = "5s";
        StartLimitIntervalSec = "0";
      };

      services.nginx.upstreams.authentik = {
        servers."127.0.0.1:9443" = {};
        extraConfig = ''
          keepalive 10;
        '';
      };

      modules.services.nginx.enable = true;
      modules.services.nginx.virtualHosts."sso.shiro.lan" = {
        default = true;
        ssl = true;
        locations."/" = {
          proxyWebsockets = true;
          recommendedProxySettings = true;
          proxyPass = "https://authentik";
        };
      };
    };
  };
}
