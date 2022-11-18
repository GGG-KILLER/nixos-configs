# This isn't an actual container, just the reverse proxying configuration.
{
  config,
  lib,
  ...
}:
with lib; let
  ct = config.modules.containers;
  proxy = {
    firefly-iii = ["money.lan" "importer.money.lan"];
    home-assistant = ["hass.lan" "esphome.lan"];
    jellyfin = ["jellyfin.lan"];
    pgsql-dev = ["pgdev.shiro.lan"];
    pgsql-prd = ["pgprd.shiro.lan"];
    qbittorrent = ["qbittorrent.lan" "flood.lan"];
    sonarr = ["sonarr.lan" "jackett.lan"];
  };
  proxy-processed = flatten (mapAttrsToList (name: domains: map (domain: {inherit name domain;}) domains) proxy);
in {
  modules.services.nginx.virtualHosts = listToAttrs (map (entry:
    nameValuePair entry.domain {
      extraConfig = ''
        set_real_ip_from 192.168.0.0/16;
      '';
      locations."/" = {
        proxyPass = "http://${head (splitString "/" ct.${entry.name}.localAddress)}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 1G;
          proxy_buffering off;
          proxy_cache off;
          proxy_read_timeout 6h;
        '';
      };
    })
  proxy-processed);
}
