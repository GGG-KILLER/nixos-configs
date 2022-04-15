{ ... }:

{
  # ZFS maintenance settings.
  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "rpool" ];
  services.zfs.autoSnapshot.enable = true;
}
