{
  stdenv,
  lib,
  fetchzip,
  fuse,
  installShellFiles,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "rclone";
  version = "1.59.1";

  src = fetchzip {
    url = "https://github.com/rclone/rclone/releases/download/v${version}/rclone-v${version}-linux-amd64.zip";
    hash = "sha256-R2E62M1Q8QOOwegz+UtyrAJkB0I9Rx4+4Sn4kOwxG80=";
  };

  buildInputs = [fuse];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/bin $out/rclone
    ls
    cp rclone.1 $out/rclone/
    cp rclone $out/bin/

    wrapProgram $out/bin/rclone \
                --suffix PATH : "${lib.makeBinPath [fuse]}" \
                --prefix LD_LIBRARY_PATH : "${fuse}/lib"
  '';

  postInstall = ''
    installManPage $out/rclone/rclone.1

    for shell in bash zsh fish; do
      $out/bin/rclone genautocomplete $shell rclone.$shell
      installShellCompletion rclone.$shell
    done
  '';

  meta = with lib; {
    description = "";
    homepage = "";
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
