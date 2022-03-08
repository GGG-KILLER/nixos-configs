{ lib, ... }:

with lib;
{
  imports = [
    ./node-exporter-smartmon.nix
    ./node.nix
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
    scrape_interval = "5s";
  };
}
