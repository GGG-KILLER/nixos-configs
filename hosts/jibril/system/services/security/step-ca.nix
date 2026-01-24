{ lib, config, ... }:
{
  jibril.dynamic-ports = [ "step-ca" ];

  # ACME Settings
  security.acme = lib.mkForce {
    acceptTerms = true; # kinda pointless since we never use upstream
    defaults = {
      server = "https://ca.lan:${toString config.jibril.ports.step-ca}/acme/acme/directory";
      renewInterval = "hourly";
    };
  };

  systemd.services =
    (lib.flip lib.mapAttrs' config.security.acme.certs (
      name: _: {
        name = "acme-${name}";
        value = {
          wants = [ "step-ca.service" ];
          after = [ "step-ca.service" ];
        };
      }
    ))
    // {
      caddy = {
        wants = [ "step-ca.service" ];
        after = [ "step-ca.service" ];
      };
    };

  # This is only for the nginx config of the downloader.
  services.caddy.virtualHosts."ca.lan".extraConfig = ''
    # Allow people to download the root cert
    @root {
      path root.crt
      path root.pem
    }
    respond @root <<PEM
    ${config.my.secrets.pki.root-crt}
    PEM

    # Allow people to download the intermediate cert
    @intermediate {
      path intermediate.crt
      path intermediate.pem
    }
    respond @root <<PEM
    ${config.my.secrets.pki.intermediate-crt}
    PEM

    # Allow people to download the full bundle of root + intermediate cert
    @bundle {
      path bundle.crt
      path bundle.pem
    }
    respond @bundle <<PEM
    ${config.my.secrets.pki.root-crt}
    ${config.my.secrets.pki.intermediate-crt}
    PEM

    # Proxy rest to Step CA
    reverse_proxy https://127.0.0.1:${toString config.jibril.ports.step-ca}
  '';

  services.step-ca = {
    enable = true;
    address = "127.0.0.1";
    port = config.jibril.ports.step-ca;
    intermediatePasswordFile = config.age.secrets.step-ca-intermediate-key-password.path;
    # See https://smallstep.com/docs/step-ca/configuration#basic-configuration-options
    settings = {
      root = config.my.secrets.pki.root-crt-path;
      crt = config.my.secrets.pki.intermediate-crt-path;
      key = config.age.secrets.step-ca-intermediate-key.path;
      dnsNames = [ "ca.lan" ];
      logger.format = "text";
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
        badgerFileLoadingMode = "";
      };
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "24h";
          defaultTLSCertDuration = "24h";
        };
        policy = {
          x509 = {
            allow = {
              dns = [
                "*.lan"
                "*.shiro.lan"
                "*.jibril.lan"
                "*.hass.lan"
                "*.ggg.dev"
              ];
            };
            allowWildcardNames = true;
          };
        };
        provisioners = [
          {
            type = "ACME";
            name = "acme";
            forceCN = true;
            caaIdentities = [ "ca.lan" ];
            challenges = [ "http-01" ];
          }
        ];
        backdate = "1m0s";
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA"
          "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA"
          "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
          "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"
          "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"
          "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
          "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"
          "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
          "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };
}
