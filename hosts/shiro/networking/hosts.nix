{
  config,
  lib,
  ...
}:
with lib; let
  networking = mapAttrs (netName: netCfg: netCfg // {names = [netCfg.name] ++ netCfg.extraNames;}) config.my.networking;
  hostToNameValPair = host: nameValuePair host.ipAddr (map (name: "${name}.lan") host.names);
in {
  networking.hosts = listToAttrs (map hostToNameValPair (attrValues networking));
}
