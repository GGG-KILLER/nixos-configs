{ pkgs, ... }:
{
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.powertop.enable = true;
  powerManagement.scsiLinkPolicy = "min_power";

  # configures an udev rule which automatically runs hdparm to enable power saving modes for rotational hard disks mapped to /dev/sd*.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 6 /dev/%k"
  '';
}
