{...}: {
  modules.services.nginx = {
    enable = true;

    virtualHosts."pub.shiro.lan" = {
      ssl = true;
      root = "/zfs-main-pool/data/http-public";
    };
  };
}
