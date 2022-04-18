{ lib
, fetchzip
, openssl
, fontconfig
, libkrb5
, zlib
, stdenv
, autoPatchelfHook
, which
}:

stdenv.mkDerivation rec {
  pname = "git-credential-manager";
  version = "2.0.696";


  src = fetchzip {
    url = "https://github.com/GitCredentialManager/git-credential-manager/releases/download/v${version}/gcmcore-linux_amd64.${version}.tar.gz";
    hash = "sha256-RploAqKPT3jpN5WsBc/swfZUYoagv0HE32pUpfSJoXI=";
    stripRoot = false;
  };

  buildInputs = runtimeDependencies ++ [
    stdenv.cc.cc
    libkrb5
    fontconfig
    zlib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  runtimeDependencies = [
    openssl
    which
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r . $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "API Support for your favorite torrent trackers";
    homepage = "https://github.com/GitCredentialManager/git-credential-manager/";
    license = licenses.mit;
    maintainers = [{
      email = "gggkiller2@gmail.com";
      github = "GGG-KILLER";
      name = "GGG";
    }];
    platforms = platforms.all;
  };
}
