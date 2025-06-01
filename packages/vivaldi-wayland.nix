# Source #1: https://github.com/NixOS/nixpkgs/pull/292148#issuecomment-2343586641
# Source #2: https://github.com/matklad/config/blob/8062c8b8a15eabc7e623d2dab9e98cc8b26bdc48/hosts/packages.nix#L6-L18
{
  callPackage,
  vivaldi-ffmpeg-codecs,
  widevine-cdm,
}:
let
  vivaldi = callPackage ./vivaldi/package.nix { };
in
vivaldi.override {
  proprietaryCodecs = true;
  inherit vivaldi-ffmpeg-codecs;
  enableWidevine = true;
  inherit widevine-cdm;
}
