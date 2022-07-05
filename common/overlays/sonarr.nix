{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      sonarr = (super.sonarr.overrideAttrs
        (oldAttrs: rec {
          version = "3.0.6.1342";

          src = pkgs.fetchurl {
            url = "https://download.sonarr.tv/v3/main/${version}/Sonarr.main.${version}.linux.tar.gz";
            hash = "sha512-kIkPVPLmsuGJLP1R4zidQuMEg10COj0zxVw+8rhT5V6pm82Teo7/AzEoKYLDK7ttgd1+YPfR9nptAIOP6x552A==";
          };
        })
      );
    })
  ];
}
