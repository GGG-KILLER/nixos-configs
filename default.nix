{ pkgs ? import <nixpkgs> {
    config = { allowUnfree = true; };
  }
}:
{
  shiro = pkgs.callPackage ./hosts/shiro/test.nix { };
}
