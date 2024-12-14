{
  lib,
  config,
  pkgs,
  ...
}:
let
  upgradeZfs =
    zfs:
    zfs.overrideAttrs (
      prev:
      assert (prev.version == "2.3.0-rc3");
      rec {
        name = lib.replaceStrings [ "2.3.0-rc3" ] [ version ] prev.name;
        version = "2.3.0-rc4";

        src = pkgs.fetchFromGitHub {
          owner = "openzfs";
          repo = "zfs";
          rev = "zfs-${version}";
          hash = "sha256-6O+XQvggyVCZBYpx8/7jbq15tLZsvzmDqp+AtEb9qFU=";
        };

        # configureFlags = prev.configureFlags ++ [ "--enable-linux-experimental" ];
        meta = prev.meta // {
          broken = false;
        };
      }
    );
in
{
  # Unstable is needed for 6.12
  boot.zfs.package = upgradeZfs pkgs.zfs_unstable;
  boot.zfs.modulePackage =
    upgradeZfs
      config.boot.kernelPackages.${config.boot.zfs.package.kernelModuleAttribute};

  # Expand all devices on boot
  services.zfs.expandOnBoot = "all";

  # Enable auto-scrub
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  # Enable auto-trim
  services.zfs.trim.enable = true;

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
}
