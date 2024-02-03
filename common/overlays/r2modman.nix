{...}: {
  nixpkgs.overlays = [
    (self: super: {
      r2modman = super.r2modman.overrideDerivation (oldAttrs: rec {
        version = "3.1.46";

        src = super.fetchFromGitHub {
          owner = "PedroVH";
          repo = "r2modmanPlus";
          rev = version;
          hash = "sha256-m6PREv1h+DHIhUmBA7nZJOiTPoZT5siddKkz9+ZMET4=";
        };

        patches = [];
      });
    })
  ];
}
