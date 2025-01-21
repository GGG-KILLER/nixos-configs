{ config, ... }:
{
  security.pki.certificateFiles = [
    config.my.secrets.pki.root-crt-path
  ];
}
