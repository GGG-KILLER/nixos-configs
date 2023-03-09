{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.age) secrets;
  step-ca-port = 1443;
in {
  # ACME Settings
  security.acme = mkForce {
    acceptTerms = true; # kinda pointless since we never use upstream
    defaults = {
      server = "https://ca.lan:${toString step-ca-port}/acme/acme/directory";
      renewInterval = "hourly";
    };
  };

  # This is only for the nginx config of the downloader.
  modules.services.nginx.virtualHosts."ca.lan" = {
    ssl = true;
    locations."/".proxyPass = "https://127.0.0.1:${toString step-ca-port}";
    locations."= /root.crt".alias = config.my.secrets.pki.root-crt-path;
    locations."= /intermediate.crt".alias = config.my.secrets.pki.intermediate-crt-path;
  };

  systemd.services = flip mapAttrs' config.security.acme.certs (name: _: {
    name = "acme-${name}";
    value = {
      after = ["step-ca.service"];
      requires = ["step-ca.service"];
    };
  });

  networking.firewall.allowedTCPPorts = [step-ca-port];
  services.step-ca = {
    enable = true;
    address = "0.0.0.0";
    port = step-ca-port;
    intermediatePasswordFile = secrets.step-ca-intermediate-key-password.path;
    # See https://smallstep.com/docs/step-ca/configuration#basic-configuration-options
    settings = {
      dnsNames = ["ca.lan"];
      root = config.my.secrets.pki.root-crt-path;
      crt = config.my.secrets.pki.intermediate-crt-path;
      key = secrets.step-ca-intermediate-key.path;
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
        badgerFileLoadingMode = "";
      };
      authority = {
        provisioners = [
          {
            type = "ACME";
            name = "acme";
            forceCN = true;
          }
        ];
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "24h";
          defaultTLSCertDuration = "24h";
        };
        backdate = "1m0s";
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
          "TLS_AES_128_GCM_SHA256"
          "TLS_AES_256_GCM_SHA384"
          "TLS_CHACHA20_POLY1305_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };
}
