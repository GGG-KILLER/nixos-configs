{ config, lib, my-lib, ... }:

with lib;
let
  inherit (my-lib) fs;
  inherit (config.my.secrets.services) backblaze;
in
{
  services.restic.backups =
    let
      allBase = {
        initialize = true;
        paths = [
          "/home/ggg"
        ];
        extraBackupArgs = [
          "--exclude=/home/ggg/Data"
          "--exclude=/home/ggg/Downloads"
          "--exclude=/home/ggg/Git"
          "--exclude=/home/ggg/Unity"
          "--exclude=/home/ggg/.cache"
          "--exclude=/home/ggg/.compose-cache"
          "--exclude=/home/ggg/.dotnet"
          "--exclude=/home/ggg/.java"
          "--exclude=/home/ggg/.nix-defexpr"
          "--exclude=/home/ggg/.nix-profile"
          "--exclude=/home/ggg/.nuget"
          "--exclude=/home/ggg/.nv"
          "--exclude=/home/ggg/.omnisharp"
          "--exclude=/home/ggg/.pki"
          "--exclude=/home/ggg/.templateengine"
          "--exclude=/home/ggg/.vscode"
          "--exclude=/home/ggg/.var/app/com.valvesoftware.Steam/.local/share/Steam"
        ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
        passwordFile = config.age.secrets.backup-password.path;
        timerConfig = {
          OnCalendar = "daily";
        };
      };
    in
    {
      all-local = mkMerge [
        allBase
        {
          repository = "/mnt/DataExt/all";
        }
      ];
      all-b2 = mkMerge [
        allBase
        {
          repository = "rclone:b2:ggg-backups-sora";
          rcloneConfig = {
            type = "b2";
            hard_delete = true;
            account = backblaze.backup-sora.keyId;
            key = backblaze.backup-sora.applicationKey;
            download_url = "https://20f939184fd4f6b7.ggg.dev";
          };
        }
      ];
    };
}
