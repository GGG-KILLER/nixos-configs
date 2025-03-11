{ lib, pkgs, ... }:
let
  base = 0;
  getSeq = num: lib.fixedWidthNumber 4 (base + num);
in
{
  services.opensnitch.rules."${getSeq 0}-allow-localhost" = {
    name = "${getSeq 0}-allow-localhost";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "regexp";
      sensitive = false;
      operand = "dest.ip";
      data = "^(127\\.0\\.0\\.1|::1)$";
    };
  };
  services.opensnitch.rules."${getSeq 1}-allow-dns" = {
    name = "${getSeq 1}-allow-dns";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "dest.port";
          data = "53";
        }
        {
          type = "simple";
          operand = "dest.ip";
          data = "192.168.1.1";
        }
      ];
    };
  };
  services.opensnitch.rules."${getSeq 2}-systemd-resolved" = {
    name = "${getSeq 2}-systemd-resolved";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "simple";
      sensitive = false;
      operand = "process.path";
      data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
    };
  };
  services.opensnitch.rules."${getSeq 3}-systemd-timesyncd" = {
    name = "${getSeq 3}-systemd-timesyncd";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "simple";
      sensitive = false;
      operand = "process.path";
      data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
    };
  };
}
