# Example to create a bios compatible gpt partition
{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/disk/by-id/ata-SSD_PDJX20250204711";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
          };
          ESP = {
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              mountpoint = "/partition-root";
              subvolumes = {
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                  ];
                };
                "/etc" = {
                  mountpoint = "/etc";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/var/lib" = {
                  mountpoint = "/var/lib";
                  mountOptions = [
                    "compress=zstd"
                  ];
                };
                "/var/log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/var/spool" = {
                  mountpoint = "/var/spool";
                  mountOptions = [
                    "compress=zstd"
                  ];
                };
                "/home/root" = {
                  mountpoint = "/root";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
