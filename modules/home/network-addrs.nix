{ lib, ... }:
{
  options.home.addrs = lib.mkOption {
    internal = true;
    description = "Addresses of things in my home network.";
    type = with lib.types; attrsOf str;
    readOnly = true;
  };

  config.home.addrs = {
    router = "10.0.0.1";

    # Jibril: 10.0.2.8/30
    jibril = "10.0.2.9";

    # Shiro: 10.0.2.0/29
    shiro-main = "10.0.2.1";
    shiro-vpn-gateway = "10.0.2.2";
    shiro-qbittorrent = "10.0.2.3";
    shiro-jellyfin = "10.0.2.4";
  };
}
