{
  pkgs,
  nodejs,
}: let
  inherit
    (pkgs)
    stdenv
    lib
    callPackage
    fetchFromGitHub
    fetchurl
    nixosTests
    ;

  since = version: lib.versionAtLeast nodejs.version version;
  before = version: lib.versionOlder nodejs.version version;
in
  final: prev: {
    "@jesec/flood" = prev."@jesec/flood".override {
      buildInputs = [final.node-pre-gyp];
    };
  }
