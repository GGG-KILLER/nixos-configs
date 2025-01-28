{
  fetchFromGitHub,
  callPackage,
}:
let
  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "m3u8-dl";
    rev = "c073e522fae317425125276c69fcdb790cd0c3da";
    hash = "sha256-YH2mHURNVEoayv6hL66Q1SB8wjE/lSbCr0GBxYHRLro=";
  };
in
callPackage src { }
