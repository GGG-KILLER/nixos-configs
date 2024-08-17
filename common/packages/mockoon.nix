{ appimageTools, fetchurl }:
appimageTools.wrapType2 rec {
  name = "mockoon-${version}";
  version = "8.4.0";
  src = fetchurl {
    # https://github.com/mockoon/mockoon/releases/download/v8.4.0/mockoon-8.4.0.x86_64.AppImage
    url = "https://github.com/mockoon/mockoon/releases/download/v${version}/mockoon-${version}.x86_64.AppImage";
    sha256 = "sha256-AjfoDqTCOJxvcpo08J8rTR8QKjUhs+U7WvR9sK64mVI=";
  };
  meta.mainProgram = "mockoon-${version}";
}
