{config, ...}: {
  # Unstable is needed for 6.4
  boot.zfs.enableUnstable = true;

  # ZFS boot settings.
  boot.supportedFilesystems = ["zfs" "ntfs"];

  # ZFS maintenance settings.
  services.zfs.trim.enable = true;

  # Expand all devices on boot
  #services.zfs.expandOnBoot = "all"; # TODO: re-enable once zpool-auto-expand-partitions gets fixed

  # Enable auto-scrub
  services.zfs.autoScrub.enable = true;

  # Enable auto-snapshot
  services.zfs.autoSnapshot = {
    enable = true;
    monthly = 0;
    weekly = 0;
    daily = 2;
  };

  # Enable ZED's pushbullet compat
  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_NOTIFY_VERBOSE = "1";
    ZED_SLACK_WEBHOOK_URL = config.my.secrets.discord.webhook + "/slack";
  };

  # ZFS Flags
  boot.kernelParams = ["zfs.zfs_arc_max=6442450944" "elevator=none" "nohibernate"];
}
