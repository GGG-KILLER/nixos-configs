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

    environment.etc = {
      "ssl/home-ca-chain.pem".text = ''
        ${builtins.readFile ./intermediate.pem}
        ${builtins.readFile ./root.pem}
      '';
      "ssl/home-ca-root.pem".source = ./root.pem;
      "ssl/home-ca-intermediate.pem".source = ./intermediate.pem;
    }
    ;
  };
}
