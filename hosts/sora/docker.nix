{...}: {
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    storageDriver = "zfs";
    autoPrune.enable = true;
  };
}
