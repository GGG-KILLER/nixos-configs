{ ... }:
{
  modules.services.nginx.enable = true;
  services.nginx.resolver.addresses = [ "192.168.2.2" ];
}
