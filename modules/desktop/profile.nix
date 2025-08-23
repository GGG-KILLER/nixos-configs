{ self, lib, config, ... }:
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
    sudo-rs
    users
    zsh
  ];

  boot.tmp.cleanOnBoot = true;

  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  };

  security.sudo-rs.extraRules = [
    # Allow to switch configurations through execution of
    # "/nix/store/*/bin/switch-to-configuration" by users
    # `ggg`, `root` without a password.
    {
      users = [
        "ggg"
        "root"
      ];
      commands = [
        {
          command = "/nix/store/*/bin/switch-to-configuration";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
        {
          command = "${lib.getExe config.nix.package} build --no-link --profile /nix/var/nix/profiles/system /nix/store/*-nixos-system-*";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
