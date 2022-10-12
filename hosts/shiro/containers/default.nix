{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./downloader.nix
    ./firefly-iii.nix
    ./home-assistant.nix
    ./jellyfin.nix
    ./network-share.nix
    ./openspeedtest.nix
    ./pgsql.nix
    #./pz-server.nix
    ./qbittorrent.nix
    ./sonarr.nix
    ./vpn-gateway.nix
  ];

  systemd.services = let
    containersNeedingVpn = filterAttrs (n: v: v.useVpn) config.my.networking;
    servicesNeedingVpn =
      mapAttrs'
      (name: netCfg: {
        name = "container@${name}";
        value = {
          after = mkIf netCfg.useVpn ["container@vpn-gateway.service"];
        };
      })
      containersNeedingVpn;
    needsStepCA =
      mapAttrs'
      (name: _: {
        name = "containers@${name}";
        value = {
          after = ["step-ca.service"];
          requires = ["step-ca.service"];
        };
      })
      config.my.networking;
  in
    mkMerge [
      servicesNeedingVpn
      needsStepCA
      {
        "container@vpn-gateway".wantedBy = map (name: "container@${name}.service") (attrNames containersNeedingVpn);
      }
    ];
}
