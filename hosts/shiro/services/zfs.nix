{ lib, config, ... }:
{
  config = lib.mkIf (!config.cost-saving.enable || !config.cost-saving.disable-hdds) {
    # Expand all devices on boot
    services.zfs.expandOnBoot = "all";

    # Enable auto-scrub
    services.zfs.autoScrub.enable = true;
    services.zfs.autoScrub.interval = "weekly";

    # Enable auto-trim
    services.zfs.trim.enable = true;

    # Enable auto-snapshot
    services.zfs.autoSnapshot.enable = true;

    # Enable ZED's pushbullet compat
    services.zfs.zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_NOTIFY_VERBOSE = "1";
      ZED_SLACK_WEBHOOK_URL = config.my.secrets.discord.webhook + "/slack";
    };
  };
}
