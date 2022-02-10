{ config, lib, ... }:

with lib;
{
  imports = [
    ./jellyfin.nix
    ./network-share.nix
    ./openspeedtest.nix
    ./qbittorrent.nix
    ./sonarr.nix
    ./vpn-gateway.nix
  ];

  systemd.services =
    let
      containersNeedingVpn = filterAttrs (n: v: v.useVpn) config.my.networking;
      servicesNeedingVpn = mapAttrs'
        (name: netCfg: {
          name = "container@${name}";
          value = {
            after = mkIf netCfg.useVpn [ "container@vpn-gateway.service" ];
          };
        })
        containersNeedingVpn;
    in
    mkMerge [
      servicesNeedingVpn
      {
        "container@vpn-gateway".wantedBy = map (name: "container@${name}.service") (attrNames containersNeedingVpn);
      }
    ];
}
