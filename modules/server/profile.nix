{ self, ... }:
{
  imports = with self.nixosModules; [
    common-programs
    groups
    hm-cleanup
    i18n
    nix-settings
    home-pki
    server-services
    sudo-rs
    users-ggg
    users-service-users
    zsh
  ];

  ggg.common-programs.enable = true;
  ggg.groups.enable = true;
  ggg.hm-cleanup.enable = true;
  ggg.i18n.enable = true;
  ggg.nix-settings.enable = true;
  ggg.sudo-rs.enable = true;
  ggg.users.ggg.enable = true;
  ggg.users.service-users.enable = true;
  ggg.zsh.enable = true;

  # Add the .lan to the end of the hostname in fqdn and dns searches
  networking.domain = "lan";
  networking.search = [ "lan" ];

  boot.tmp.cleanOnBoot = true;

  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  };
}
