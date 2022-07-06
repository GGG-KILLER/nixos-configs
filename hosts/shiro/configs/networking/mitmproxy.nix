{ config, ... }:

{
  security.pki.certificateFiles = [
    # ./mitmproxy-ca-cert.pem
  ];
}
