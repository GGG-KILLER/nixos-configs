# Source #1: https://github.com/NixOS/nixpkgs/pull/292148#issuecomment-2343586641
# Source #2: https://github.com/matklad/config/blob/8062c8b8a15eabc7e623d2dab9e98cc8b26bdc48/hosts/packages.nix#L6-L18
{
  lib,
  vivaldi,
  qt6,
}:
let
  replaceStringsEnsuringReplaced =
    needles: replacements: haystack:
    let
      result = lib.replaceStrings needles replacements haystack;
    in
    assert result != haystack;
    result;
in
(vivaldi.overrideAttrs (oldAttrs: {
  buildPhase =
    replaceStringsEnsuringReplaced
      [ "for f in libGLESv2.so libqt5_shim.so ; do" ]
      [ "for f in libGLESv2.so libqt5_shim.so libqt6_shim.so ; do" ]
      oldAttrs.buildPhase;
})).override
  {
    qt5 = qt6;
    commandLineArgs = [ "--ozone-platform=wayland" ];
    # The following two are just my preference, feel free to leave them out
    proprietaryCodecs = true;
    enableWidevine = true;
  }
