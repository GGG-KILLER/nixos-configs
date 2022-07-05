{ pkgs ? import <nixpkgs> {
    config = { allowUnfree = true; };
  }
}:
{
  shiro = pkgs.callPackage ./servers/shiro/test.nix { };
}
