{
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  name = "mockoon-${version}";
  version = "3.0.0";
  src = fetchurl {
    url = "https://github.com/mockoon/mockoon/releases/download/v${version}/mockoon-${version}.AppImage";
    sha256 = "sha256-YGcD/8h21fUoBEAcBVI5jo0UMCKdVRdC1zxDIrHjU+8=";
  };
  extraPkgs = pkgs: with pkgs; [];
}
