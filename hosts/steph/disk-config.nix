{ ... }:
{
  disko.devices = {
    disk.root = {
      device = "/dev/disk/by-id/nvme-FORESEE_XP2000F512G_M2025121200363";
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
                subvolumes =
                  let
                    defaultMountOptions = [
                      "compress=zstd"
                      "discard=async"
                      "ssd"
                    ];
                  in
                  {
                    "/rootfs" = {
                      mountpoint = "/";
                      mountOptions = defaultMountOptions ++ [
                      ];
                    };
                    "/etc" = {
                      mountpoint = "/etc";
                      mountOptions = defaultMountOptions ++ [
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = defaultMountOptions ++ [
                        "noatime"
                      ];
                    };
                    "/var/lib" = {
                      mountpoint = "/var/lib";
                      mountOptions = defaultMountOptions ++ [
                      ];
                    };
                    "/var/log" = {
                      mountpoint = "/var/log";
                      mountOptions = defaultMountOptions ++ [
                        "noatime"
                      ];
                    };
                    "/var/spool" = {
                      mountpoint = "/var/spool";
                      mountOptions = defaultMountOptions ++ [
                      ];
                    };
                    "/home/root" = {
                      mountpoint = "/root";
                      mountOptions = defaultMountOptions ++ [
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = defaultMountOptions ++ [
                        "noatime"
                      ];
                    };
                    "/home/ggg" = { };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
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
