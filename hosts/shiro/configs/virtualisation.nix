{...}: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    autoPrune.enable = true;
    daemon.settings = {
      insecure-registries = [
        "shiro.lan:5000"
      ];
    };
  };
}
