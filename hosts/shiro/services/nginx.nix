{ config, ... }:
{
  modules.services.nginx.enable = true;
  services.nginx.resolver.addresses = [ config.home.addrs.router ];
}
