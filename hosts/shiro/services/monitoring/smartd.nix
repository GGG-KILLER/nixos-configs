{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) getExe getExe';
in
{
  services.smartd =
    let
      jq = getExe pkgs.jq;
      cut = getExe' pkgs.coreutils "cut";
      rev = getExe' pkgs.util-linux "rev";
      escape-str =
        varName: ''$(echo "${varName}" | ${jq} -Rs . | ${cut} -c 2- | ${rev} | ${cut} -c 2- | ${rev})'';
      notifyScript = pkgs.writeScript "smartd-discord-notify.sh" ''
        ${getExe' pkgs.discord-sh "discord.sh"} \
          --webhook-url="${config.my.secrets.discord.webhook}" \
          --title "$SMARTD_FAILTYPE" \
          --author smartd \
          --description "${escape-str "$SMARTD_FULLMESSAGE"}" \
          --footer "on $SMARTD_DEVICE" \
          --timestamp
      '';
    in
    {
      enable = true;

      # Only run the tests and stuff for the disks we list here
      autodetect = false;
      devices = [
        { device = "/dev/disk/by-id/ata-SanDisk_Ultra_II_960GB_170517421132"; }
        { device = "/dev/disk/by-id/ata-TOSHIBA_HDWQ140_41HAK6DMFBJG"; }
        { device = "/dev/disk/by-id/ata-TOSHIBA_HDWQ140_41HAK6DOFBJG"; }
        { device = "/dev/disk/by-id/ata-TOSHIBA_HDWQ140_X03BK19PFBJG"; }
        { device = "/dev/disk/by-id/ata-TOSHIBA_HDWQ140_X037K5Q6FBJG"; }
      ];

      notifications.mail.enable = false;
      notifications.wall.enable = false;
      notifications.x11.enable = false;
      # Alerts for the default attributes with -a
      # Runs the following tests with -s:
      #   Offline self-test midnight, 6 AM, 12 PM and 6 PM every day
      #   Short self-test 2 AM every day (gets skipped on long test days)
      #   Long self-test 1 AM every saturday
      # Disables emailing with -m <nomailer>
      # Runs a custom script for notifications with -M exec
      defaults.monitored = "-a -s (O/../.././(00|06|12|18)|S/../.././02|L/../../6/01) -m <nomailer> -M exec ${notifyScript}";
    };
}
