{...}: {
  nixpkgs.overlays = [
    (self: super: {
      r2modman = super.r2modman.overrideDerivation (oldAttrs: rec {
        version = "3.1.45";

        src = super.fetchFromGitHub {
          owner = "PedroVH";
          repo = "r2modmanPlus";
          rev = version;
          hash = "sha256-1sPj/5ltvgZQQ+6bTA2zSU+fIYdC/4jWzWwIz2vnq5c=";
        };

        patches = [];
      });
    })
  ];
}
