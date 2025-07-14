{ config, lib, ... }:
{
  security.sudo.enable = false;

  security.sudo-rs.enable = true;
  security.sudo-rs.execWheelOnly = true;
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
          command = "${lib.getExe config.nix.package} build --no-link --profile /nix/var/nix/profiles/system /nix/store/[a-z0-9]+-nixos-system-(sora|shiro)-[\d.]+";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
