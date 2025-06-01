{ lib, ... }:
{
  options.cost-saving.enable = lib.mkEnableOption "cost-saving mode";
  options.cost-saving.disable-hdds = lib.mkOption {
    description = "Whether to turn off the HDDs RAID-10 array when cost-saving mode is on.";
    type = lib.types.bool;
    default = true;
  };
  options.cost-saving.disable-downloaders = lib.mkOption {
    description = "Whether to turn off the downloader services when cost-saving mode is on.";
    type = lib.types.bool;
    default = true;
  };
  options.cost-saving.disable-streaming = lib.mkOption {
    description = "Whether to turn off the streaming services when cost-saving mode is on.";
    type = lib.types.bool;
    default = true;
  };
  options.cost-saving.scrape-interval = lib.mkOption {
    description = "The slower scraping interval to use when cost-saving mode is on.";
    type = lib.types.str;
    default = "1m";
  };

  config.cost-saving.enable = true;
}
