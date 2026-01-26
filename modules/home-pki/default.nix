{ lib, config, ... }:
{
  options.ggg.home-pki = {
    enable = (lib.mkEnableOption "the home PKI infra") // {
      default = true;
    };

    root-certificate = lib.mkOption {
      description = "The store path to the root certificate.";
      type = with lib.types; nullOr pathInStore;
      readOnly = true;
    };

    intermediate-certificate = lib.mkOption {
      description = "The store path to the root certificate.";
      type = with lib.types; nullOr pathInStore;
      readOnly = true;
    };
  };

  config = lib.mkIf config.ggg.home-pki.enable {
    ggg.home-pki.root-certificate = ./root.pem;
    ggg.home-pki.intermediate-certificate = ./intermediate.pem;

    security.pki.certificateFiles = [
      config.ggg.home-pki.root-certificate
    ];
  };
}
