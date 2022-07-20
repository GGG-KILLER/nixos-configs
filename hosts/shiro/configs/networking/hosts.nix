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
        name =
          if netCfg.name != null
          then netCfg.name
          else netName;
      in
        netCfg
        // {
          inherit name;
          names = [name] ++ netCfg.extraNames;
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
      "${name}"
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
