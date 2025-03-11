{ lib, pkgs, ... }:
let
  base = 30;
  getSeq = num: lib.fixedWidthNumber 4 (base + num);
in
{
  services.opensnitch.rules."${getSeq 0}-rclone-allow-backblaze" = {
    name = "${getSeq 0}-rclone-allow-backblaze";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "dest.port";
          data = "443";
        }
        {
          type = "simple";
          operand = "user.id";
          data = "0";
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.rclone}/bin/.rclone-wrapped";
        }
        {
          type = "regexp";
          operand = "dest.host";
          data = "^(|.*\\.)backblaze(|b2)\\.com$";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 1}-rclone-allow-gggdotdev" = {
    name = "${getSeq 1}-rclone-allow-gggdotdev";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "dest.port";
          data = "443";
        }
        {
          type = "simple";
          operand = "user.id";
          data = "0";
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.rclone}/bin/.rclone-wrapped";
        }
        {
          type = "regexp";
          operand = "dest.host";
          data = "^(|.*\\.)ggg\\.dev$";
        }
      ];
    };
  };
}
