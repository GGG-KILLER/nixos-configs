{
  lib,
  buildGoModule,
  fetchFromGitHub,
  lm_sensors,
}:
buildGoModule {
  pname = "lm-sensors-exporter";
  version = "edcd531";

  src = fetchFromGitHub {
    owner = "janw";
    repo = "lm-sensors-exporter";
    rev = "edcd5313d88c6203a5a2f5a39d715cfef379665c";
    sha256 = "sha256-lGhpZ8esDoyzLcqdBpcTOtk6CRHsyJnwk2Vc0SWHeRk=";
  };

  vendorHash = null;

  postConfigure = ''
    substituteInPlace vendor/github.com/ncabatoff/gosensors/gosensors.go \
      --replace '"/etc/sensors3.conf"' '"${lm_sensors}/etc/sensors3.conf"'
  '';

  CGO_CFLAGS = "-I ${lm_sensors}/include";
  CGO_LDFLAGS = "-L ${lm_sensors}/lib";

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Prometheus exporter for sensor data like temperature and fan speed";
    homepage = "https://github.com/janw/lm-sensors-exporter";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.unix;
  };
}
