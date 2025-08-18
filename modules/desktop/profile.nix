{ self, lib, config, ... }:
{
  imports = with self.nixosModules; [
    common-programs
    ggg-password
    ggg-programs
    groups
    i18n
    nix-settings
    pki
    sudo-rs
    users
    zsh
  ];

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
          command = "${lib.getExe config.nix.package} build --no-link --profile /nix/var/nix/profiles/system /nix/store/[a-z0-9]+-nixos-system-(sora|shiro)-[\w.]+";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
