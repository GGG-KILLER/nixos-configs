{
  lib,
  pkgs,
  config,
  ...
}:
{
  # ACME Settings
  security.acme = lib.mkForce {
    acceptTerms = true; # kinda pointless since we never use upstream
    defaults = {
      server = "https://ca.lan/acme/home/directory";
      renewInterval = "hourly";
    };
  };

  # Secrets
  age.secrets."root.key" = {
    file = ../../../../../secrets/jibril/ca/root.key.age;
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
  };
  age.secrets."intermediate.key" = {
    file = ../../../../../secrets/jibril/ca/intermediate.key.age;
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
  };

  # Configure CA
  services.caddy.globalConfig = ''
    pki {
      ca home {
        name "Home.Lan CA"

        root {
          format pem_file
          cert ${config.ggg.home-pki.root-certificate}
          key ${config.age.secrets."root.key".path}
        }

        intermediate {
          format pem_file
          cert ${config.ggg.home-pki.intermediate-certificate}
          key ${config.age.secrets."intermediate.key".path}
        }
      }
    }

    # Use home CA
    cert_issuer internal {
      ca home
    }
  '';

  # Configure the ACME Server
  services.caddy.virtualHosts."ca.lan".extraConfig = ''
    # Allow people to download the root and intermediate certificates
    root ${
      pkgs.runCommand "ca-static-files"
        {
          nativeBuildInputs = [ pkgs.openssl ];

          rootCert = config.ggg.home-pki.root-certificate;
          intermediateCert = config.ggg.home-pki.intermediate-certificate;
        }
        ''
          mkdir $out

          # PEM files for Unix
          cp "$rootCert" "$out"/root.pem
          cp "$intermediateCert" "$out"/intermediate.pem

          # CER files for Windows MMC
          openssl x509 -in "$rootCert" -out "$out"/root.cer
          openssl x509 -in "$intermediateCert" -out "$out"/intermediate.cer

          # CRT files for ?
          openssl x509 -in "$rootCert" -out "$out"/root.crt
          openssl x509 -in "$intermediateCert" -out "$out"/intermediate.crt

          # PFX files for Windows Certificates Manager
          openssl x509 -in "$rootCert" -out "$out"/root.pfx
          openssl x509 -in "$intermediateCert" -out "$out"/intermediate.pfx

          # DER files for ?
          openssl x509 -in "$rootCert" -out "$out"/root.der
          openssl x509 -in "$intermediateCert" -out "$out"/intermediate.der
        ''
    }
    file_server {
      pass_thru
    }

    # Handle ACME for rest
    acme_server {
      ca home

      allow {
        domains *.lan
        domains *.shiro.lan
        domains *.jibril.lan
        domains *.sora.lan
        domains *.steph.lan
        domains *.hass.lan
      }
    }
  '';
}
