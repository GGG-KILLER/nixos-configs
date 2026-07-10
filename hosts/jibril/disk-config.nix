{ ... }:
{
  disko.devices = {
    disk.root = {
      device = "/dev/disk/by-id/ata-SanDisk_SD9SB8W-256G-1006_1930CJ442415";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          crypted-root = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted-root";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                mountpoint = "/partition-root";
                subvolumes = {
                  "/rootfs" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                    ];
                  };
                  "/etc" = {
                    mountpoint = "/etc";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                      "noatime"
                    ];
                  };
                  "/var/lib" = {
                    mountpoint = "/var/lib";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                    ];
                  };
                  "/var/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                      "noatime"
                    ];
                  };
                  "/var/spool" = {
                    mountpoint = "/var/spool";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                    ];
                  };
                  "/home/root" = {
                    mountpoint = "/root";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
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
  };
}
