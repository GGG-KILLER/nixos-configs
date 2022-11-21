{...}: {
  virtualisation.docker = {
    enable = true;
    # enableNvidia = true;
    # storageDriver = "zfs";
    autoPrune.enable = true;

    # only start up on demand
    enableOnBoot = false;
  };
}
