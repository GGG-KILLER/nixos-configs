{ config, ... }:
{
  # LUKS root device — hand-written since shiro doesn't use disko.
  # PARTUUID of /dev/sda1; the inner btrfs UUID (used by fileSystems.* in
  # hardware-configuration.nix) is unchanged by the in-place reencryption.
  boot.initrd.luks.devices."crypted-root" = {
    device = "/dev/disk/by-partuuid/e597cb45-b78a-4cdc-8ba0-8e79e1bf1fa1";
    allowDiscards = true; # root is an SSD
    bypassWorkqueues = true;
  };

  # initrd networking — shared by Clevis and the manual SSH fallback.
  boot.initrd.availableKernelModules = [ "r8169" ];

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ]; # throwaway key, generated on-host
      # `command=` forces SSH to run this instead of a login shell, so we
      # don't need root's shell binary to exist inside the initrd image.
      authorizedKeys = map (
        key: ''command="systemctl default" ${key}''
      ) config.users.users.ggg.openssh.authorizedKeys.keys;
    };
  };

  # ip=client::gw:netmask:host:iface:autoconf
  boot.kernelParams = [
    "ip=${config.home.addrs.shiro-main}::${config.home.addrs.router}:255.255.0.0::enp6s0:none"
  ];

  # Clevis auto-unlock via jibril's Tang; falls back to the normal passphrase
  # prompt (console or initrd-SSH) whenever Tang is unreachable.
  #
  # The JWE is shipped through environment.etc (part of the closure) rather
  # than referenced as a source path: initrd secrets are appended to the
  # initrd at *activation* time on the target from a context-stripped path,
  # so a flake-source path breaks on remote deploys (the checkout only
  # exists on the build machine).
  environment.etc."clevis/root.jwe".source = ./root.jwe;
  boot.initrd.clevis.enable = true;
  boot.initrd.clevis.useTang = true;
  boot.initrd.clevis.devices."crypted-root".secretFile = "/etc/clevis/root.jwe";
}
