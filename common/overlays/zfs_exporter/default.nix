{ lib, buildGoModule, fetchFromGitHub, makeWrapper, zfs, config, nixosTests, invalidateFetcherByDrvHash }:

buildGoModule rec {
  pname = "prometheus-zfs-exporter";
  version = "2.2.5";

  src = invalidateFetcherByDrvHash fetchFromGitHub {
    owner = "pdf";
    repo = "zfs_exporter";
    rev = "v${version}";
    sha256 = "sha256-niLv3ohFJol/Qsa3+wX91tF7WEdK/wWO7kbYztVdM+E=";
  };

  vendorSha256 = "sha256-jQiw3HlqWcsjdadDdovCsDMBB3rnWtacfbtzDb5rc9c=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/zfs_exporter \
      --prefix PATH : "${zfs}/bin"
  '';

  meta = {
    homepage = "https://github.com/pdf/zfs_exporter";
    description = "ZFS exporter for Prometheus";
    license = lib.licenses.mit;
  };
}
