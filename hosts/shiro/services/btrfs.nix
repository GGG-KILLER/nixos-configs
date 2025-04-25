{ ... }:
{
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];
  services.btrfs.autoScrub.interval = "weekly";

  services.beesd.filesystems.root = {
    spec = "/";
    hashTableSizeMB = 4 * 1024;
    extraOptions = [
      "--timestamps"
      "--thread-min"
      "2"
      "--loadavg-target"
      "8.0"
      # TODO: Enable when v0.11 releases
      # "--throttle-factor"
      # "1"
    ];
    verbosity = "warning";
  };
}
