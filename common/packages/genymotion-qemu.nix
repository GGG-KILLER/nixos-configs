# Credits to https://github.com/NixOS/nixpkgs/issues/226867#issuecomment-1913102626
{
  gdk-pixbuf,
  xdg-utils,
  cairo,
  fetchurl,
  fontconfig,
  freetype,
  glib,
  gtk3,
  lib,
  libGL,
  libpulseaudio,
  libXext,
  libXi,
  libxkbcommon,
  libXmu,
  libXrender,
  makeWrapper,
  pixman,
  stdenv,
  systemd,
  which,
  xorg,
  zlib,
}: let
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    zlib
    glib
    xorg.libX11
    libxkbcommon
    libXmu
    libXi
    libXext
    libGL
    libXrender
    fontconfig
    freetype
    systemd
    pixman
    libpulseaudio
    gtk3
    cairo
    gdk-pixbuf
  ];
in
  stdenv.mkDerivation rec {
    pname = "genymotion";
    version = "3.6.0";
    src = fetchurl {
      url = "https://dl.genymotion.com/releases/genymotion-${version}/genymotion-${version}-linux_x64.bin";
      name = "genymotion-${version}-linux_x64.bin";
      sha256 = "sha256-CS1A9udt47bhgnYJqqkCG3z4XaPVHmz417VTsY2ccOA=";
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [which xdg-utils];

    unpackPhase = ''
      mkdir -p phony-home $out/share/applications
      export HOME=$TMP/phony-home

      mkdir ${pname}
      echo "y" | sh $src -d ${pname}
      sourceRoot=${pname}

      substitute phony-home/.local/share/applications/genymobile-genymotion.desktop \
        $out/share/applications/genymobile-genymotion.desktop --replace "$TMP/${pname}" "$out/libexec"
    '';

    installPhase = ''
      mkdir -p $out/bin $out/libexec
      mv genymotion $out/libexec/
      ln -s $out/libexec/genymotion/{genymotion,player} $out/bin
    '';

    fixupPhase = ''
      patchInterpreter() {
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          "$out/libexec/genymotion/$1"
      }

      patchExecutable() {
        patchInterpreter "$1"
        wrapProgram "$out/libexec/genymotion/$1" \
          --set "LD_LIBRARY_PATH" "${libPath}" \
          --unset "QML2_IMPORT_PATH" \
          --unset "QT_PLUGIN_PATH"
      }

      patchTool() {
        patchInterpreter "tools/$1"
        wrapProgram "$out/libexec/genymotion/tools/$1" \
          --set "LD_LIBRARY_PATH" "${libPath}"
      }

      patchExecutable genymotion
      patchExecutable player
      patchInterpreter qemu/x86_64/bin/{qemu-system-x86_64,qemu-img}

      patchTool adb
      patchTool aapt
      patchTool glewinfo

      rm $out/libexec/genymotion/libxkbcommon*
    '';
  }
