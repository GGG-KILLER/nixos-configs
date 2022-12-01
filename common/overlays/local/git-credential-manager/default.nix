{
  lib,
  autoPatchelfHook,
  fetchzip,
  fontconfig,
  icu,
  libkrb5,
  libsecret,
  libunwind,
  libX11,
  makeWrapper,
  openssl_1_1,
  stdenv,
  libICE,
  libSM,
  zlib,
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
    version = "2.0.877";

    src = fetchzip {
      url = "https://github.com/GitCredentialManager/git-credential-manager/releases/download/v${version}/gcm-linux_amd64.${version}.tar.gz";
      hash = "sha256-Mr548yaKkLSQm6sASWtYJ/1hk6Dgyek1ai+mcrWNn+c=";
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
      chmod +x git-credential-manager
      chmod +x git-credential-manager-ui

      mkdir -p $out/bin

      makeWrapper $gcmlibs/git-credential-manager $out/bin/git-credential-manager \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}" \
        --set DOTNET_CLI_TELEMETRY_OPTOUT 1

      makeWrapper $gcmlibs/git-credential-manager-ui $out/bin/git-credential-manager-ui \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath (libraries ++ [libICE libSM])}" \
        --set DOTNET_CLI_TELEMETRY_OPTOUT 1
    '';

    meta = with lib; {
      description = "Secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services.";
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
