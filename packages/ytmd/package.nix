{
  lib,
  fetchFromGitHub,
  makeWrapper,
  electron,
  python3,
  stdenv,
  copyDesktopItems,
  nodejs,
  pnpm,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ytmd";
  version = "3.11.0";

  src = fetchFromGitHub {
    owner = "ytmd-devs";
    repo = "ytmd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M8YFpeauM55fpNyHSGQm8iZieV0oWqOieVThhglKKPE=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-xZQ8rnLGD0ZxxUUPLHmNJ6mA+lnUHCTBvtJTiIPxaZU=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3
    nodejs
    pnpm.configHook
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ copyDesktopItems ];

  ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  postBuild =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      cp -R ${electron.dist}/Electron.app Electron.app
      chmod -R u+w Electron.app
    ''
    + ''
      pnpm build
      ./node_modules/.bin/electron-builder \
        --dir \
        -c.electronDist=${if stdenv.hostPlatform.isDarwin then "." else electron.dist} \
        -c.electronVersion=${electron.version}
    '';

  installPhase = ''
    runHook preInstall

  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/{Applications,bin}
    mv pack/mac*/YouTube\ Music.app $out/Applications
    makeWrapper $out/Applications/YouTube\ Music.app/Contents/MacOS/YouTube\ Music $out/bin/youtube-music
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mkdir -p "$out/share/lib/youtube-music"
    cp -r pack/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/youtube-music"

    pushd assets/generated/icons/png
    for file in *.png; do
      install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/youtube-music.png
    done
    popd
  ''
  + ''

    runHook postInstall
  '';

  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    makeWrapper ${electron}/bin/electron $out/bin/youtube-music \
      --add-flags $out/share/lib/youtube-music/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  patches = [
    # MPRIS's DesktopEntry property needs to match the desktop entry basename
    ./fix-mpris-desktop-entry.patch
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "com.github.th_ch.youtube_music";
      exec = "youtube-music %u";
      icon = "youtube-music";
      desktopName = "YouTube Music";
      startupWMClass = "com.github.th_ch.youtube_music";
      categories = [ "AudioVideo" ];
    })
  ];

  meta = with lib; {
    description = "Electron wrapper around YouTube Music";
    homepage = "https://ytmd-devs.github.io/ytmd/";
    changelog = "https://github.com/ytmd-devs/ytmd/blob/master/changelog.md#${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.src.rev
    }";
    license = licenses.mit;
    maintainers = with maintainers; [
      ggg
    ];
    mainProgram = "youtube-music";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
