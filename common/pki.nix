{config, ...}: {
  security.pki.certificateFiles = [
    #config.my.secrets.pki.root-crt-path
    config.my.secrets.pki.intermediate-crt-path
  ];
}
