{ ... }:
{
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];
  services.btrfs.autoScrub.interval = "weekly";

  services.beesd.filesystems.root = {
    spec = "/";
    hashTableSizeMB = 512;
    # extraOptions = [
    #   "--timestamps"
    #   "--thread-min"
    #   "2"
    #   "--loadavg-target"
    #   "8.0"
    #   "--throttle-factor"
    #   "1"
    # ];
    # verbosity = "warning";
  };
}
