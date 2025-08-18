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

  boot.tmp.cleanOnBoot = true;

  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  };
}
