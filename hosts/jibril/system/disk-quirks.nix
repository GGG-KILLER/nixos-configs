{ ... }:
{
  # This SSD (serial SSD_PDJX20250204711) has a hardware fault (likely marginal power delivery)
  # where NCQ write bursts reliably trigger SATA bus errors (ATA bus error / UnrecovData Handshk),
  # reproduced consistently in a rescue environment. Forcing queue depth to 1 disables NCQ and
  # avoids the fault. Stopgap until the machine is replaced.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ENV{ID_SERIAL}=="SSD_PDJX20250204711", ATTR{device/queue_depth}="1"
  '';
}
