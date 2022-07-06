{ config, ... }:

{
  security.pki.certificateFiles = [
    my.secrets.pki.root-crt-path
    my.secrets.pki.intermediate-crt-path
  ];
}
