{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./lm-sensors.nix
    ./node.nix
    ./smartmon-exporter.nix
    ./zfs-exporter.nix
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
    instance = "shiro";
    scrape_interval = if config.cost-saving.enable then config.cost-saving.scrape-interval else "5s";
  };
}
