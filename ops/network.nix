{
  network = {
    description = "home network";
  };

  "shiro.lan" = { config, pkgs, ... }:
    {
      imports = [ ../hosts/shiro/configuration.nix ];

      deployment.targetUser = "root";
      deployment.targetHost = "shiro.lan";
    };
}
