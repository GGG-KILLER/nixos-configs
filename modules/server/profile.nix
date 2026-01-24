{ self, ... }:
{
  imports = with self.nixosModules; [
    common-programs
    ggg-password
    ggg-programs
    groups
    hm-cleanup
    i18n
    nix-settings
    pki
    server-services
    sudo-rs
    users
    zsh
  ];

  # Add the .lan to the end of the hostname in fqdn and dns searches
  networking.domain = "lan";
  networking.search = [ "lan" ];

  boot.tmp.cleanOnBoot = true;

  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  };
}
