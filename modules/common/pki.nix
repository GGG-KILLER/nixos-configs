{ config, ... }:
{
  imports = [ ./secrets/pki.nix ];

  security.pki.certificateFiles = [
    config.my.secrets.pki.root-crt-path
  ];
}
