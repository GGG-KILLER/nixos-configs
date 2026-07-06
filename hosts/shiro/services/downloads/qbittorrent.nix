{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf (!config.cost-saving.enable || !config.cost-saving.disable-downloaders) {
    services.qbittorrent = {
      enable = true;
      package = pkgs.qbittorrent-nox;
      user = "my-torrent";
      group = "data-members";
      profileDir = "/var/lib/qBittorrent";
      webuiPort = config.shiro.ports.qbittorrent-web;
    };

    services.caddy.virtualHosts."qbittorrent.lan".extraConfig =
      "reverse_proxy http://127.0.0.1:${toString config.shiro.ports.qbittorrent-web}";

    systemd.services.qbittorrent = {
      after = [
        "storage-animu.mount"
        "storage-etc.mount"
        "storage-h.mount"
        "storage-series.mount"
      ];
      requires = [
        "storage-animu.mount"
        "storage-etc.mount"
        "storage-h.mount"
        "storage-series.mount"
      ];
    };

    # BitTorrent listening port (DHT/peers).
    networking.firewall.allowedTCPPorts = [ 6881 ];
    networking.firewall.allowedUDPPorts = [ 6881 ];
  };
}
