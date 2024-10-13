{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  cacert,
  ffmpeg,
  git,
  makeBinaryWrapper,
  mediainfo,
  nodejs,
  python39,
  streamlink,
  symlinkJoin,
  vcsi,
  yarn-berry,
  yt-dlp,
}:
let
  name = "live-stream-dvr";

  src = fetchFromGitHub {
    owner = "MrBrax";
    repo = "LiveStreamDVR";
    rev = "34a1d961de184a6ac6fc5f00f4bfc90926c21c21";
    fetchSubmodules = true;
    hash = "sha256-QcVNgtOJhJtVSLJJqox/lmuAMIsLbmlVv3xgKBA8Qc0=";
  };

  supportedArchitectures = builtins.toJSON {
    os = [
      "linux"
    ];
    cpu = [
      "x64"
      "arm64"
    ];
    libc = [
      "glibc"
    ];
  };

  fetchYarnDeps =
    {
      name,
      src,
      sha256,
    }:
    stdenvNoCC.mkDerivation {
      inherit name src supportedArchitectures;

      nativeBuildInputs = [ yarn-berry ];

      NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";

      configurePhase = ''
        runHook preConfigure
        export HOME="$NIX_BUILD_TOP"
        export YARN_ENABLE_TELEMETRY=0
        yarn config set enableGlobalCache false
        yarn config set cacheFolder $out
        yarn config set supportedArchitectures --json "$supportedArchitectures"
        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild
        mkdir -p $out
        yarn install --immutable --mode skip-build
        runHook postBuild
      '';

      dontInstall = true;

      outputHashAlgo = "sha256";
      outputHash = sha256;
      outputHashMode = "recursive";
    };

  vodChatOfflineCache = fetchYarnDeps {
    name = "${name}-twitch-vod-chat-deps";
    src = "${src}/twitch-vod-chat";
    sha256 = "sha256-qLXjbZFQAfFTnDAjJTt8gLqnscOW+vcCGD7BQPVRn3g=";
  };

  clientOfflineCache = fetchYarnDeps {
    name = "${name}-client-vue-deps";
    src = "${src}/client-vue";
    sha256 = "sha256-1XJAx+WSUMyOi3alPHrF4Z4MimVIr73ykWlkUifd550=";
  };

  serverOfflineCache = fetchYarnDeps {
    name = "${name}-server-deps";
    src = "${src}/server";
    sha256 = "sha256-sk/s1LCaY1avedibxkfuLxxdhiVQXlgsU6fbUydOlNg=";
  };

  chatDumperOfflineCache = fetchYarnDeps {
    name = "${name}-twitch-chat-dumper-deps";
    src = "${src}/twitch-chat-dumper";
    sha256 = "sha256-ZwBjioTq/1RQiuxsaTfpcsysX/qNf2BvN5Y54+567Yw=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit name src supportedArchitectures;
  version = "0-unstable-2024-10-12";

  nativeBuildInputs = [
    nodejs
    yarn-berry
    git
    makeBinaryWrapper
  ];

  binDir = symlinkJoin {
    name = "live-stream-dvr-bin";
    paths = [
      nodejs
      python39
      ffmpeg
      mediainfo
      streamlink
      yt-dlp
      vcsi
    ];
  };

  dontPatch = true; # Nothing to patch.

  configurePhase = ''
    runHook preConfigure

    function yarnInstall() {
      pushd "$1"
      {
        export HOME="$NIX_BUILD_TOP"
        export YARN_ENABLE_TELEMETRY=0

        yarn config set enableGlobalCache false
        yarn config set supportedArchitectures --json "$supportedArchitectures"
        yarn config set cacheFolder $2

        yarn install --immutable --immutable-cache
      }
      popd
    }

    yarnInstall twitch-vod-chat "${vodChatOfflineCache}"
    yarnInstall client-vue "${clientOfflineCache}"
    yarnInstall server "${serverOfflineCache}"
    yarnInstall twitch-chat-dumper "${chatDumperOfflineCache}"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    pushd twitch-vod-chat
    yarn run build
    yarn run buildlib
    popd

    pushd client-vue
    yarn run build
    popd

    pushd server
    yarn run build
    popd

    pushd twitch-chat-dumper
    yarn run build
    popd

    runHook postBuild
  '';

  installPhase = ''
    # Copy Twitch Chat Dumper files
    mkdir -p $out/lib/twitch-chat-dumper/
    cp -r twitch-chat-dumper/{build,package.json} $out/lib/twitch-chat-dumper/

    # Copy VOD Player files
    mkdir -p $out/lib/twitch-vod-chat/
    cp -r twitch-vod-chat/{dist,package.json,LICENSE} $out/lib/twitch-vod-chat/

    # Copy Server files
    mkdir -p $out/lib/server/
    cp -r server/{build,package.json,tsconfig.json,LICENSES.txt} $out/lib/server/

    # Copy Client files
    mkdir -p $out/lib/client-vue/
    cp -r client-vue/{dist,package.json,LICENSES.txt} $out/lib/client-vue/

    # Create public folder (this is done because it tries to create it if doesn't
    #                       exist and fails to because the store is readonly)
    mkdir -p $out/lib/public/

    # Make a wrapper so that people can run this easily
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/livestreamdvr \
      --add-flags "--enable-source-maps" \
      --add-flags $out/lib/server/build/server.js \
      --set-default TCD_BIN_DIR "$binDir/bin" \
      --set TCD_FFMPEG_PATH "${lib.getExe ffmpeg}" \
      --set TCD_MEDIAINFO_PATH "${lib.getExe mediainfo}" \
      --set TCD_NODE_PATH "${lib.getExe nodejs}" \
      --set TCD_BIN_PATH_PYTHON "${lib.getExe python39}" \
      --set TCD_PYTHON_ENABLE_PIPENV "0"
  '';

  meta = {
    description = "An automatic livestream recorder";
    homepage = "https://github.com/MrBrax/LiveStreamDVR";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ggg ];
    mainProgram = "livestreamdvr";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
