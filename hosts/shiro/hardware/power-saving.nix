{ pkgs, ... }:
{
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.powertop.enable = true;
  powerManagement.scsiLinkPolicy = "min_power";
}
