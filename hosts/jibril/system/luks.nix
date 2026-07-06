{ config, ... }:
{
  boot.initrd.availableKernelModules = [ "e1000e" ]; # jibril NIC

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      # `command=` forces SSH to run this instead of a login shell, so we don't need root's
      # shell binary to exist inside the initrd image.
      authorizedKeys = map (
        key: ''command="systemctl default" ${key}''
      ) config.users.users.ggg.openssh.authorizedKeys.keys;
    };
  };

  # Static addressing in the initrd (DHCP is off on jibril). ip=client::gw:netmask:host:iface:autoconf
  boot.kernelParams = [
    "ip=${config.home.addrs.jibril}::${config.home.addrs.router}:255.255.0.0::enp0s31f6:none"
  ];
}
