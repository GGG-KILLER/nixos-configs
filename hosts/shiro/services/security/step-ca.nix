{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce flip mapAttrs';
  inherit (config.age) secrets;
in
{
  # ACME Settings
  security.acme = mkForce {
    acceptTerms = true; # kinda pointless since we never use upstream
    defaults = {
      server = "https://ca.lan:${toString config.shiro.ports.step-ca}/acme/acme/directory";
      renewInterval = "hourly";
    };
  };

  # This is only for the nginx config of the downloader.
  modules.services.nginx.virtualHosts."ca.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:${toString config.shiro.ports.step-ca}";
      recommendedProxySettings = true;
    };
    locations."= /bundle.crt".alias = pkgs.writeText "bundle.crt" ''
      ${config.my.secrets.pki.root-crt}
      ${config.my.secrets.pki.intermediate-crt}
    '';
    locations."= /root.crt".alias = config.my.secrets.pki.root-crt-path;
    locations."= /intermediate.crt".alias = config.my.secrets.pki.intermediate-crt-path;
  };

  systemd.services = flip mapAttrs' config.security.acme.certs (
    name: _: {
      name = "acme-${name}";
      value = {
        after = [ "step-ca.service" ];
        requires = [ "step-ca.service" ];
      };
    }
  );

  networking.firewall.allowedTCPPorts = [ config.shiro.ports.step-ca ];
  services.step-ca = {
    enable = true;
    address = "0.0.0.0";
    port = config.shiro.ports.step-ca;
    intermediatePasswordFile = secrets.step-ca-intermediate-key-password.path;
    # See https://smallstep.com/docs/step-ca/configuration#basic-configuration-options
    settings = {
      root = config.my.secrets.pki.root-crt-path;
      crt = config.my.secrets.pki.intermediate-crt-path;
      key = secrets.step-ca-intermediate-key.path;
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
                "*.money.lan"
                "*.shiro.lan"
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
