{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests,
}:
buildGoModule rec {
  pname = "node_exporter";
  version = "1.3.1";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "prometheus";
    repo = "node_exporter";
    sha256 = "sha256-+0k9LBsHqNHmoOAY1UDzbbqni+ikj+c3ijfT41rCfLc=";
  };

  vendorHash = "sha256-nAvODyy+PfkGFAaq+3hBhQaPji5GUMU7N8xcgbGQMeI=";

  # FIXME: tests fail due to read-only nix store
  doCheck = false;

  excludedPackages = [ "docs/node-mixin" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${version}"
    "-X github.com/prometheus/common/version.Revision=${rev}"
    "-X github.com/prometheus/common/version.Branch=unknown"
    "-X github.com/prometheus/common/version.BuildUser=nix@nixpkgs"
    "-X github.com/prometheus/common/version.BuildDate=unknown"
  ];

  passthru.tests = {
    inherit (nixosTests.prometheus-exporters) node;
  };

  meta = with lib; {
    description = "Prometheus exporter for machine metrics";
    homepage = "https://github.com/prometheus/node_exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [
      benley
      fpletz
      globin
      Frostman
    ];
  };
}
