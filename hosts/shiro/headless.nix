{ ... }:
# Headless stuff that we can use.
# We have a console so we don't actually want *all* of the headless settings.
{
  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
  ];

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;
}
