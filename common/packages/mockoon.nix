{ appimageTools, fetchurl }:
appimageTools.wrapType2 rec {
  name = "mockoon-${version}";
  version = "8.0.0";
  src = fetchurl {
    # https://github.com/mockoon/mockoon/releases/download/v8.0.0/mockoon-8.0.0.x86_64.AppImage
    url = "https://github.com/mockoon/mockoon/releases/download/v${version}/mockoon-${version}.x86_64.AppImage";
    sha256 = "sha256-mhUjV8yFXS76kJDj28VeIv4/PlnKos/Ugo9k3RHnRaM=";
  };
  meta.mainProgram = "mockoon-${version}";
}
