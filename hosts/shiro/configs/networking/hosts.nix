{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  networking =
    mapAttrs (
      netName: netCfg: let
        inherit (netCfg) name;
      in
        netCfg
        // {
          names = [netCfg.name] ++ netCfg.extraNames;
        }
    )
    config.my.networking;
  hostToNameValPair = host: let
    names = host.names;
    ipAddrs = host.ipAddrs;
    genNames = name: [
      # "${name}.home-server.ggg.dev"
      # "${name}.home-server.ggg"
      # "${name}.home-server"
      "${name}.lan"
    ];
  in
    assert (ipAddrs ? "clan" || ipAddrs ? "elan");
      nameValuePair
      ipAddrs
      .${
        if ipAddrs ? "clan"
        then "clan"
        else "elan"
      } (concatMap genNames names);
in {
  networking.hosts = listToAttrs (map hostToNameValPair (attrValues networking));
}
