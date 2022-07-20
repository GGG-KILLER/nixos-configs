{
  lib,
  fetchzip,
  fontconfig,
  icu,
  libkrb5,
  libsecret,
  libunwind,
  libX11,
  openssl_1_1,
  zlib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
}: let
  libraries = [
    fontconfig
    icu
    libkrb5
    libsecret
    libunwind
    libX11
    openssl_1_1
    stdenv.cc.cc
    zlib
  ];
in
  stdenv.mkDerivation rec {
    pname = "git-credential-manager";
    version = "2.0.696";

    src = fetchzip {
      url = "https://github.com/GitCredentialManager/git-credential-manager/releases/download/v${version}/gcmcore-linux_amd64.${version}.tar.gz";
      hash = "sha256-RploAqKPT3jpN5WsBc/swfZUYoagv0HE32pUpfSJoXI=";
      stripRoot = false;
    };

    buildInputs = libraries;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    installPhase = ''
      gcmlibs=$out/share/gcm
      mkdir -p $gcmlibs

      cp -r * $gcmlibs

      chmod +x Atlassian.Bitbucket.UI
      chmod +x GitHub.UI
      chmod +x GitLab.UI
      chmod +x git-credential-manager-core

      mkdir -p $out/bin

      makeWrapper $gcmlibs/git-credential-manager-core $out/bin/git-credential-manager-core \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}" \
        --set TERM xterm --set DOTNET_CLI_TELEMETRY_OPTOUT 1
    '';

    meta = with lib; {
      description = "API Support for your favorite torrent trackers";
      homepage = "https://github.com/GitCredentialManager/git-credential-manager/";
      license = licenses.mit;
      maintainers = [
        {
          email = "gggkiller2@gmail.com";
          github = "GGG-KILLER";
          name = "GGG";
        }
      ];
      platforms = platforms.all;
    };
  }
