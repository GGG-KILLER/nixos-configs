# Based on: https://github.com/Pablo1107/dotfiles/blob/4a2463f44bb3b45971ebd9d445b099fd3fa70f24/overlays/moises-desktop.nix#L6
{ fetchurl, appimageTools }:
let
  pname = "moises-desktop";
  version = "0-unstable-2026-07-22"; # They don't have proper versioning, the hash changes but version doesn't.
  src = fetchurl {
    url = "https://desktop.moises.ai/";
    curlOptsList = [
      "-H"
      "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36"
    ];
    hash = "sha256-bl9eHJpWBMYVAitKyQvQKYgB74EPtSO5wo8pw6bdJOQ=";
  };
  appimageContents = appimageTools.extract { inherit pname src version; };
in
appimageTools.wrapType2 {
  inherit pname src version;
  extraPkgs = pkgs: [ ];
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/moises-desktop.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/moises-desktop.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';
}
