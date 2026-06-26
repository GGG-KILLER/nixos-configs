{ lib, config, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.ggg.sudo-rs;
in
{
  options.ggg.sudo-rs.enable = mkEnableOption "sudo-rs in place of sudo, restricted to wheel";

  config = mkIf cfg.enable {
    security.sudo.enable = false;
    security.sudo-rs.enable = true;
    security.sudo-rs.execWheelOnly = true;
  };
}
