{...}: {
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;

    # only start up on demand
    enableOnBoot = false;
  };
}
