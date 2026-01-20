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

  modules.services.nginx.virtualHosts."files.shiro.lan" = {
    ssl = true;

    extraConfig = ''
      # Allow special characters in headers
      ignore_invalid_headers off;
      # Allow any size file to be uploaded.
      # Set to a value such as 1000m; to restrict file size to a specific value
      client_max_body_size 0;
      # Disable buffering
      proxy_buffering off;
      proxy_request_buffering off;
    '';

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.shiro.ports.mikochi}";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_connect_timeout 300;
        chunked_transfer_encoding off;
      '';
    };
  };
}
