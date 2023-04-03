{
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  name = "mockoon-${version}";
  version = "1.23.0";
  src = fetchurl {
    url = "https://github.com/mockoon/mockoon/releases/download/v${version}/mockoon-${version}.AppImage";
    sha256 = "sha256-1ez+V6bVlyku/zr3puDaPya+P9CQAKTLMF/F23yvpH0=";
  };
  extraPkgs = pkgs: with pkgs; [];
}
