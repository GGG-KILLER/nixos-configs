{ pkgs ? import <nixpkgs> {
    config = { allowUnfree = true; };
  }
}:

{
  virt-v2v = pkgs.callPackage ./default.nix { };
}
