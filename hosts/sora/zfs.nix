{ config, ... }:

{
  # ZFS maintenance settings.
  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "rpool" ];
  services.zfs.autoSnapshot.enable = true;

  # Enable ZED's pushbullet compat
  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_NOTIFY_VERBOSE = "1";
    ZED_PUSHBULLET_ACCESS_TOKEN = config.my.secrets.modules.pushbullet.accessToken;
    ZED_SLACK_WEBHOOK_URL = config.my.secrets.discord.webhook + "/slack";
  };
}
