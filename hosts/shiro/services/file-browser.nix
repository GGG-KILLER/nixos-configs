{
  self,
  system,
  config,
  ...
}:
{
  virtualisation.oci-containers.containers.mikochi = rec {
    imageFile = self.packages.${system}.docker-images."zer0tonin/mikochi:latest";
    image = imageFile.destNameTag;
    user = "${toString config.users.users.file-browser.uid}:${toString config.users.groups.data-members.gid}";
    ports = [ "${toString config.shiro.ports.mikochi}:61252" ];
    environment = {
      HOST = "0.0.0.0:61252";
      USERNAME = "ggg";
    };
    environmentFiles = [ config.age.secrets."mikochi.env".path ];
    volumes = [
      "/storage/h:/data/h"
      "/storage/etc:/data/etc"
    ];
    extraOptions = [
      "--cap-drop=ALL"
      "--ipc=none"
    ];
  };

  services.caddy.virtualHosts."files.shiro.lan".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.shiro.ports.mikochi} {
      flush_interval -1
    }
  '';

  systemd.services."docker-mikochi" = {
    after = [
      "storage-etc.mount"
      "storage-h.mount"
    ];
    requires = [
      "storage-etc.mount"
      "storage-h.mount"
    ];
  };
}
