{
  lib,
  writeShellScript,
  fetchurl,
  stdenvNoCC,
  unzip,
  copyDesktopItems,
  makeDesktopItem,
  copyDesktopIcons,
  makeDesktopIcon,
  wineWowPackages,
  winetricks,

  finalWine ? wineWowPackages.staging,
}:
let
  launchScript = writeShellScript "perfview-wrapper" ''
    set -euo pipefail

    export WINE="${lib.getExe' finalWine "wine"}"
    export WINEPREFIX="''${DNSPY_HOME:-"''${XDG_DATA_HOME:-"''${HOME}/.local/share"}/PerfView"}/wine"
    export WINEDEBUG=-all
    export WINEARCH=win32
    if [ ! -d "$WINEPREFIX" ]; then
      mkdir -p "$WINEPREFIX"
    fi

    ${lib.getExe' finalWine "wineboot"} -u
    ${lib.getExe winetricks} -q arial d3dcompiler_47 dxvk dotnet48 win10 webview2
    "$WINE" reg add "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Avalon.Graphics" /v DisableHWAcceleration -d "dword:00000001" /f

    exec "$WINE" "''${ENTRYPOINT:-@out@/opt/PerfView/PerfView.exe}" "$@"
  '';
in
stdenvNoCC.mkDerivation rec {
  pname = "PerfView";
  version = "3.1.18";

  srcs = [
    (fetchurl {
      url = "https://github.com/microsoft/perfview/releases/download/v${version}/PerfView.exe";
      hash = "sha256-O7eQhrauHKqm03+pX/cqKUfH9zXx+RCp19ArePPSsSk=";
    })
    (fetchurl {
      name = "Microsoft.Diagnostics.Tracing.TraceEvent.${version}.zip";
      url = "https://github.com/microsoft/perfview/releases/download/v${version}/Microsoft.Diagnostics.Tracing.TraceEvent.${version}.nupkg";
      hash = "sha256-C3RLOvgCmO4NirS+ns48TE45rlu0NoUtWroob+h12Ck=";
    })
  ];
  sourceRoot = ".";
  unpackCmd = ''
    if [[ "$curSrc" == *.zip ]]; then
      unzip "$curSrc" -d "$(stripHash "$curSrc")"
    else
      cp "$curSrc" "$(stripHash "$curSrc")"
    fi
  '';

  nativeBuildInputs = [
    unzip
    copyDesktopItems
    copyDesktopIcons
  ];

  # buildPhase = ''
  #   ls -lAFh .
  #   exit 1
  # '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/PerfView
    cp PerfView.exe $out/opt/PerfView/PerfView.exe
    mv Microsoft.Diagnostics.Tracing.TraceEvent.${version}.zip/lib/netstandard2.0/*.dll $out/opt/PerfView/
    mv Microsoft.Diagnostics.Tracing.TraceEvent.${version}.zip/build/native/amd64/*.dll $out/opt/PerfView/
    install -vD ${launchScript} $out/bin/PerfView

    substituteInPlace $out/bin/PerfView \
      --subst-var out

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "${pname} ${version}";
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 0;
    src = fetchurl {
      url = "https://github.com/microsoft/perfview/raw/refs/tags/v${version}/src/PerfView/performance.ico";
      hash = "sha256-xFG7ykhTWx55owUnNKj379rSxJl23jc0NMDzGwT/8cU=";
    };
  };

  meta = {
    description = "A CPU and memory performance-analysis tool.";
    homepage = "https://github.com/microsoft/perfview";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ggg ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "PerfView";
  };
}
