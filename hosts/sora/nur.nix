{ ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    rnix-lsp = import (builtins.fetchTarball "https://github.com/nix-community/rnix-lsp/archive/master.tar.gz");
    morph = pkgs.callPackage (pkgs.fetchFromGitHub {
      owner = "DBCDK";
      repo = "morph";
      rev = "master";
      hash = "sha256-0CHmjqPxBgALGZYjfJFLoLBnoI0U7oZ8WyCtu1bkzZg=";
    }) { };
  };
}
