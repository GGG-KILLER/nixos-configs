{
  lib,
  buildGoModule,
  fetchzip,
  lm_sensors,
}:
buildGoModule {
  pname = "lm-sensors-exporter";
  version = "edcd531";

  src = fetchzip {
    url = "https://codeberg.org/janw/lm-sensors-exporter/archive/edcd5313d88c6203a5a2f5a39d715cfef379665c.zip";
    hash = "sha256-lGhpZ8esDoyzLcqdBpcTOtk6CRHsyJnwk2Vc0SWHeRk=";
  };

  vendorHash = null;

  postConfigure = ''
    substituteInPlace vendor/github.com/ncabatoff/gosensors/gosensors.go \
      --replace '"/etc/sensors3.conf"' '"${lib.getOutput "out" lm_sensors}/etc/sensors3.conf"'
  '';

  CGO_CFLAGS = "-I ${lib.getInclude lm_sensors}/include";
  CGO_LDFLAGS = "-L ${lib.getLib lm_sensors}/lib";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Prometheus exporter for sensor data like temperature and fan speed";
    homepage = "https://github.com/janw/lm-sensors-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maintainers.ggg ];
    platforms = lib.platforms.unix;
  };
}
