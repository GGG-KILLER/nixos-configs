{ ... }:
{
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];
  services.btrfs.autoScrub.interval = "weekly";

  services.beesd.filesystems.root = {
    spec = "/";
    hashTableSizeMB = 512;
    extraOptions = [
      "--thread-min"
      "1"
      "--loadavg-target"
      "2.0"
      "--throttle-factor"
      "1"
    ];
    # verbosity = "warning";
  };
}
