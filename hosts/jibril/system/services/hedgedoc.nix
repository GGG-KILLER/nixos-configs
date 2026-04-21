{ config, ... }:
{
  services.hedgedoc.enable = true;
  services.hedgedoc.settings.domain = "notes.lan";
  services.hedgedoc.settings.path = "/run/hedgedoc/hedgedoc.sock";
  services.hedgedoc.settings.protocolUseSSL = true;

  services.hedgedoc.settings.allowAnonymous = false;
  services.hedgedoc.settings.enableUploads = "registered";

  users.users.caddy.extraGroups = [ "hedgedoc" ];
  services.caddy.virtualHosts."notes.lan".extraConfig = ''
    reverse_proxy unix/${config.services.hedgedoc.settings.path}
  '';
}
