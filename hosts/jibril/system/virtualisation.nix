{ ... }:
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    autoPrune = {
      enable = true;
      dates = "daily";
      flags = [ "--all" ];
      persistent = true;
      randomizedDelaySec = "45min";
    };
  };
}
