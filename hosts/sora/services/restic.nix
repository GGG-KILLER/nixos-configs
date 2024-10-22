{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkMerge;
in
{
  services.restic.backups =
    let
      zfs = getExe pkgs.zfs;
      allBase =
        type:
        let
          baseHomeDir = "/home/ggg/.zfs/snapshot/restic-backup-${type}";
          baseVarLibDir = "/var/lib/.zfs/snapshot/restic-backup-${type}";
          excludeFile = pkgs.writeText "restic-excludes-${type}.txt" ''
            ${baseHomeDir}/.aspnet
            ${baseHomeDir}/.cache
            ${baseHomeDir}/.compose-cache
            ${baseHomeDir}/.config/chromium
            ${baseHomeDir}/.config/Code
            ${baseHomeDir}/.config/discordcanary
            ${baseHomeDir}/.config/ftb-app
            ${baseHomeDir}/.config/Google
            ${baseHomeDir}/.config/google-chrome
            ${baseHomeDir}/.config/mockoon
            ${baseHomeDir}/.config/MongoDB Compass
            ${baseHomeDir}/.config/obs-studio
            !${baseHomeDir}/.config/obs-studio/basic
            !${baseHomeDir}/.config/obs-studio/global.ini
            ${baseHomeDir}/.config/OpenTabletDriver
            ${baseHomeDir}/.config/r2modman
            ${baseHomeDir}/.config/r2modmanPlus-local
            ${baseHomeDir}/.dir_colors
            ${baseHomeDir}/.docker
            ${baseHomeDir}/.dotnet
            ${baseHomeDir}/.ftb
            ${baseHomeDir}/.gephi
            ${baseHomeDir}/.ghidra
            ${baseHomeDir}/.gk
            ${baseHomeDir}/.irpf
            ${baseHomeDir}/.java
            ${baseHomeDir}/.local/share
            !${baseHomeDir}/.local/share/konsole
            !${baseHomeDir}/.local/share/Mindustry.bin
            !${baseHomeDir}/.local/share/Mindustry/saves
            !${baseHomeDir}/.local/share/plasma-systemmonitor
            !${baseHomeDir}/.local/share/PrismLauncher/libraries
            !${baseHomeDir}/.local/share/PrismLauncher/prismlauncher.cfg
            ${baseHomeDir}/.mongodb
            ${baseHomeDir}/.mono
            ${baseHomeDir}/.mozilla
            ${baseHomeDir}/.nix-*
            ${baseHomeDir}/.npm
            ${baseHomeDir}/.nuget
            ${baseHomeDir}/.nuxtrc
            ${baseHomeDir}/.nv
            ${baseHomeDir}/.pcsc10
            ${baseHomeDir}/.rfb
            ${baseHomeDir}/.ServiceHub
            ${baseHomeDir}/.templateengine
            ${baseHomeDir}/.var/app
            ${baseHomeDir}/.vscode
            ${baseHomeDir}/.wine
            ${baseHomeDir}/.xca
            ${baseHomeDir}/.yarn
            ${baseHomeDir}/.zshenv
            ${baseHomeDir}/.zshrc
            ${baseHomeDir}/Android
            ${baseHomeDir}/Downloads
            ${baseHomeDir}/Git
            ${baseHomeDir}/MC
            !${baseHomeDir}/MC/**/backups
            !${baseHomeDir}/MC/**/config
            !${baseHomeDir}/MC/**/instance.cfg
            !${baseHomeDir}/MC/**/instance.json
            !${baseHomeDir}/MC/**/mmc-pack.json
            !${baseHomeDir}/MC/**/saves
            ${baseHomeDir}/Music/Liked Music
            ${baseHomeDir}/random
          '';
        in
        {
          initialize = true;
          backupPrepareCommand = ''
            ${zfs} destroy rpool/userdata/home/ggg@restic-backup-${type} && echo "[backupPrepareCommand] Home snapshot deleted" || :
            ${zfs} snapshot rpool/userdata/home/ggg@restic-backup-${type} && echo "[backupPrepareCommand] Home snapshot created"
            ${zfs} destroy rpool/nixos/var/lib@restic-backup-${type} && echo "[backupPrepareCommand] Lib snapshot deleted" || :
            ${zfs} snapshot rpool/nixos/var/lib@restic-backup-${type} && echo "[backupPrepareCommand] Lib snapshot created"
          '';
          backupCleanupCommand = ''
            ${zfs} destroy rpool/userdata/home/ggg@restic-backup-${type} && echo "[backupCleanupCommand] Home snapshot deleted"
            ${zfs} destroy rpool/nixos/var/lib@restic-backup-${type} && echo "[backupCleanupCommand] Lib snapshot deleted"
          '';
          paths = [
            # Backup home dir
            baseHomeDir
            # Backup VM images
            "${baseVarLibDir}/libvirt/images"
          ];
          extraBackupArgs = [
            "--compression max"
            "--exclude-file=${excludeFile}"
          ];
          pruneOpts = [
            "--group-by hosts"
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
      all-b2 = mkMerge [
        (allBase "b2")
        {
          repository = "rclone:b2:ggg-backups-sora";
          rcloneConfig = {
            type = "b2";
            hard_delete = true;
          };
          environmentFile = config.age.secrets.backup-envfile.path;
        }
      ];
    };
}
