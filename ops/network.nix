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

  "vpn-proxy.ggg.dev" = { config, pkgs, ... }:
    {
      imports = [ ../hosts/vpn-proxy/configuration.nix ];

      deployment.targetUser = "root";
      deployment.targetHost = "vpn-proxy.ggg.dev";
      deployment.targetPort = 17606;
    };
}
