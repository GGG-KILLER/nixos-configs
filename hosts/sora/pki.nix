{ config, ... }:

{
  security.pki.certificateFiles = [
    config.age.secrets.step-ca-root-crt
    config.age.secrets.step-ca-intermediate-crt
  ];
}
