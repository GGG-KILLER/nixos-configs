{ ... }:
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
      ];
    }
  ];
}
