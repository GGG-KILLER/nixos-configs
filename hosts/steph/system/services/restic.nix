###
# ATTENTION: When changing anything in this file, also check hosts/sora/system/desktop/opensnitch/003x-backup-rules.nix
###
{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.restic.backups.filesystem =
    let
      zfs = lib.getExe pkgs.zfs;
      baseHomeDir = "/home/ggg/.zfs/snapshot/restic-backup";
      baseVarLibDir = "/var/lib";
    in
    rec {
      initialize = false;
      repository = "rclone:b2:ggg-restic";
      environmentFile = config.age.secrets."backup.env".path;
      passwordFile = config.age.secrets."backup.key".path;
      rcloneConfig = {
        type = "b2";
        hard_delete = true;
      };

      progressFps = 5;
      backupPrepareCommand = ''
        ${backupCleanupCommand}
        ${zfs} snapshot rpool/userdata/home/ggg@restic-backup && echo "[backupPrepareCommand] Home snapshot created"
      '';
      backupCleanupCommand = ''
        ${zfs} destroy rpool/userdata/home/ggg@restic-backup && echo "[backupCleanupCommand] Home snapshot deleted"
      '';
      paths = [
        # Backup home dir
        baseHomeDir
        # Backup VM images
        "${baseVarLibDir}/libvirt/images"
      ];
      extraBackupArgs = [
        "--compression max"
        "--tag files"
        "--exclude-file=${pkgs.writeText "restic-excludes.txt" ''
          ${baseHomeDir}/.aspnet
          ${baseHomeDir}/.cache
          ${baseHomeDir}/.cargo
          ${baseHomeDir}/.compose-cache
          ${baseHomeDir}/.config/chromium
          ${baseHomeDir}/.config/Code
          ${baseHomeDir}/.config/discordcanary
          ${baseHomeDir}/.config/ftb-app
          ${baseHomeDir}/.config/Google
          ${baseHomeDir}/.config/google-chrome
          ${baseHomeDir}/.config/mockoon
          ${baseHomeDir}/.config/MongoDB Compass
          ${baseHomeDir}/.config/Screeps
          ${baseHomeDir}/.config/JetBrains
          ${baseHomeDir}/.config/Mullvad VPN
          ${baseHomeDir}/.config/obs-studio
          !${baseHomeDir}/.config/obs-studio/basic
          !${baseHomeDir}/.config/obs-studio/global.ini
          ${baseHomeDir}/.config/OpenTabletDriver
          ${baseHomeDir}/.config/r2modman
          ${baseHomeDir}/.config/r2modmanPlus-local
          ${baseHomeDir}/.dir_colors
          ${baseHomeDir}/.docker
          ${baseHomeDir}/.dotnet
          ${baseHomeDir}/.factorio
          !${baseHomeDir}/.factorio/saves
          ${baseHomeDir}/.ftb
          ${baseHomeDir}/.gephi
          ${baseHomeDir}/.ghidra
          ${baseHomeDir}/.gk
          ${baseHomeDir}/.irpf
          ${baseHomeDir}/.java
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
          ${baseHomeDir}/Pictures/Wallpapers
          ${baseHomeDir}/Documents/AI
          ${baseHomeDir}/Documents/lmms
          ${baseHomeDir}/Zomboid
          !${baseHomeDir}/Zomboid/Saves
        ''}"
      ];

      timerConfig = {
        Persistent = true;
        OnCalendar = "20:00";
      };
    };
}
