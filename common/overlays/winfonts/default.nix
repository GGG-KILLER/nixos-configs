{ lib
, stdenvNoCC
, mkfontscale
}:

stdenvNoCC.mkDerivation {
  pname = "winfonts";
  version = "1";

  src = ./fonts.tar.gz;

  installPhase = ''
    out_ttf=$out/share/fonts/truetype
    install -m444 -Dt $out_ttf *.ttf
    install -m444 -Dt $out_ttf *.ttc
  '';

  meta = {
    description = "Windows fonts ripped from a Windows 10 install";
    homepage = "https://microsoft.com";
    license = lib.licenses.unfree;

    priority = 5;
    platforms = lib.platforms.all;
  };
}
