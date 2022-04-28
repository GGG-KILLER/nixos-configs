{ lib, ... }:

with lib;
let
  zmount = name: {
    device = name;
    fsType = "zfs";
    options = [ "zfsutil" ];
  };
  rootMount = name:
    { "/${name}" = zmount name; };
  genRootMounts = names:
    mkMerge (map rootMount names);
in
{
  fileSystems = mkMerge [
    (genRootMounts [
      "zfs-main-pool/data/animu"
      "zfs-main-pool/data/etc"
      "zfs-main-pool/data/h"
      "zfs-main-pool/data/jackett"
      "zfs-main-pool/data/jellyfin"
      "zfs-main-pool/data/qbittorrent"
      "zfs-main-pool/data/sonarr"
      "zfs-main-pool/data/home-assistant"
      "zfs-main-pool/data/gaming/pz-server"
      "zfs-main-pool/data/dbs/pgsql-dev"
      "zfs-main-pool/data/dbs/pgsql-prd"
      "zfs-main-pool/data/firefly-iii"
    ])
    {
      "/var/lib/grafana" = zmount "zfs-main-pool/data/monitoring/grafana";
      "/var/lib/prometheus2" = zmount "zfs-main-pool/data/monitoring/prometheus";
      "/var/lib/docker" = zmount "zfs-main-pool/system/var/docker";
      "/mnt/backup" = {
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWD120_49GV1LAAS-part1";
        fsType = "ext4";
      };
      "/mnt/zfs-backup" = {
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWD120_49GV1LAAS-part2";
        fsType = "ext4";
      };
    }
  ];
}
