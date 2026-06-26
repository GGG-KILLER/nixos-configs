{ lib, config, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.ggg.groups;
in
{
  options.ggg.groups.enable = mkEnableOption "the pre-configured shared groups";

  config = mkIf cfg.enable {
    users.groups.data-members.gid = 1000;
  };
}
