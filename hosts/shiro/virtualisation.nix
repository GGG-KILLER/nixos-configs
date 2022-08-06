{...}: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    autoPrune.enable = true;
  };
}
