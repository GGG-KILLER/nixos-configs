{ config, ... }:

{
  security.pki.certificateFiles = [
    # ./mitmproxy-ca-cert.pem
    config.age.secrets.step-ca-root-crt
    config.age.secrets.step-ca-intermediate-crt
  ];
}
