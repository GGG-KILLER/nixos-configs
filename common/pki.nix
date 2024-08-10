{ config, ... }:
{
  security.pki.certificateFiles = [ config.my.secrets.pki.intermediate-crt-path ];
}
