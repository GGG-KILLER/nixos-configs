{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  makeWrapper,
  electron,
  python3,
  stdenv,
  copyDesktopItems,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
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

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-xZQ8rnLGD0ZxxUUPLHmNJ6mA+lnUHCTBvtJTiIPxaZU=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3
    nodejs
    pnpm
    pnpmConfigHook
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
    # Fix downloader
    (fetchpatch2 {
      url = "https://patch-diff.githubusercontent.com/raw/ytmd-devs/ytmd/pull/3973.patch";
      hash = "sha256-rlhGIltbNB3Ref9CxMVAP94O/3hp0pJX1eMIpbLNdjI=";
    })
    # Adopt ytmd-devs/ytmd#3917 early
    (fetchpatch2 {
      url = "https://patch-diff.githubusercontent.com/raw/ytmd-devs/ytmd/pull/3917.diff"; # uses the diff since there's repeated commmits in the PR somehow.
      hash = "sha256-XfcE6FqLeKO6Kz1HyNrog5aYosSqiY2i2rlxg9lqPQQ=";
    })
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
