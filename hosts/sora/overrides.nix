{ ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    morph = import (builtins.fetchTarball "https://github.com/DBCDK/morph/archive/refs/heads/master.zip") {
      inherit pkgs;
    };
  };
}
