{ lib, config, ... }:
{
  # CPU: intel_pstate + powersave governor = HWP-driven scaling
  powerManagement.cpuFreqGovernor = "powersave";

  # powertop --auto-tune at boot (runtime PM for PCI/USB/etc.)
  powerManagement.powertop.enable = true;

  # powertop --auto-tune sets power/control=auto on every USB device,
  # overriding udev rules applied at add-time; retrigger the Zigbee dongle's
  # rule (below) after it runs so the exemption wins.
  powerManagement.powertop.postStart = ''
    ${lib.getExe' config.systemd.package "udevadm"} trigger -c add -s usb -a idVendor=1a86 -a idProduct=55d4
  '';

  # SATA link power management for the SSD (+ DVD drive)
  powerManagement.scsiLinkPolicy = "med_power_with_dipm";

  # PCIe ASPM: prefer power saving on links that support it
  # (policy, not "force" — force can hang devices that don't advertise ASPM)
  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];

  # Intel HDA audio codec power-down (server, audio unused)
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1 power_save_controller=Y
  '';

  boot.kernel.sysctl = {
    # Disable the NMI watchdog (hard-lockup detector); it programs a perf
    # counter that fires periodic interrupts, keeping cores out of deep
    # C-states. Only useful when debugging kernel hangs.
    "kernel.nmi_watchdog" = 0;
    # Flush dirty pages every 15s instead of the default 5s, so disk/CPU
    # wake up a third as often for writeback. At most 15s of not-yet-synced
    # writes are lost on power loss; explicit fsync()s (databases) are
    # unaffected.
    "vm.dirty_writeback_centisecs" = 1500;
  };

  # Exempt the Zigbee dongle from the USB autosuspend that
  # powertop --auto-tune enables globally (serial latency/reliability)
  services.udev.extraRules = ''
    # Sonoff Zigbee 3.0 Dongle Plus V2 (ITEAD): 1a86:55d4
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1a86", ATTR{idProduct}=="55d4", TEST=="power/control", ATTR{power/control}="on"
  '';
}
