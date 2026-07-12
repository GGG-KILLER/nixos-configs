{ ... }:
{
  # amd-pstate-epp (bound since the F59a BIOS update exposed CPPC) requires
  # the "powersave" governor; actual perf/power balance is steered by EPP.
  powerManagement.cpuFreqGovernor = "powersave";

  # The firmware default EPP is "performance"; bias toward power saving.
  # No NixOS option exists for EPP, so write it via tmpfiles (static server,
  # no CPU hotplug to worry about).
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference - - - - balance_power"
  ];

  # powertop --auto-tune at boot (runtime PM for PCI/USB/etc.)
  powerManagement.powertop.enable = true;

  # SATA link power management (HDDs on the Marvell card + chipset SSD;
  # independent of hd-idle spindown)
  powerManagement.scsiLinkPolicy = "min_power";

  # PCIe ASPM: BIOS is set to L1 Entry and retained ASPM ownership (_OSC),
  # so firmware policy governs; this asks the kernel to prefer power saving
  # on anything it does control. Harmless if a no-op.
  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];

  # HDA codec power-down for the Quadro's HDMI audio function (the AMD
  # onboard controller is disabled in BIOS)
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
}
