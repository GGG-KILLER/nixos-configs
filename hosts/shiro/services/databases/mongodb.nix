{config, ...}: {
  virtualisation.oci-containers.containers.mongo-dev = {
    image = "mongodb/mongodb-community-server:latest";
    ports = ["${toString config.shiro.ports.mongo-dev}:27017"];
    environmentFiles = [
      config.age.secrets."mongodb/dev.env".path
    ];
    volumes = [
      "/zfs-main-pool/data/dbs/mongo-dev:/data/db"
    ];

    extraOptions = [
      "--dns=192.168.1.1"
      "--pull=always"
    ];
  };

  virtualisation.oci-containers.containers.mongo-prd = {
    image = "mongodb/mongodb-community-server:latest";
    ports = ["${toString config.shiro.ports.mongo-prd}:27017"];
    environmentFiles = [
      config.age.secrets."mongodb/prd.env".path
    ];
    volumes = [
      "/zfs-main-pool/data/dbs/mongo-prd:/data/db"
    ];

    extraOptions = [
      "--dns=192.168.1.1"
      "--pull=always"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    config.shiro.ports.mongo-dev
    config.shiro.ports.mongo-prd
  ];
}
