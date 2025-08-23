{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./lm-sensors.nix
    ./node.nix
    ./smartmon-exporter.nix
    ./zfs.nix
  ];

  options.my.constants.prometheus = {
    instance = mkOption {
      type = types.str;
      description = "The instance name to use in prometheus";
    };
    scrape_interval = mkOption {
      type = types.str;
      description = "The scrape interval to use for prometheus";
    };
  };

  config.my.constants.prometheus = {
    instance = "jibril";
    scrape_interval = "5s";
  };
}
