{
  lib,
  config,
  ...
}: {
  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/ajnart/homarr:latest";
    ports = ["${toString config.shiro.ports.homarr}:7575"];
    environment = {
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/private/ca/ca-root.pem";
    };
    volumes = [
      "/zfs-main-pool/data/homarr/configs:/app/data/configs"
      "/zfs-main-pool/data/homarr/data:/data"
      "/zfs-main-pool/data/homarr/icons:/app/public/icons"
      "${config.my.secrets.pki.root-crt-path}:/etc/ssl/certs/private/ca/ca-root.pem"
    ];
    extraOptions = [
      "--cap-drop=ALL"
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
    ];
  };

  virtualisation.oci-containers.containers.dashdot = {
    image = "mauricenino/dashdot";
    ports = ["${toString config.shiro.ports.dashdot}:3001"];
    environment = {
      DASHDOT_ALWAYS_SHOW_PERCENTAGES = "true";
    };
    volumes =
      [
        "/etc/os-release:/mnt/host/etc/os-release:ro"
        "/proc/1/ns:/mnt/host/proc/1/ns:ro"
      ]
      ++ (map (path: "${path}:/mnt/host${path}:ro") (lib.attrNames config.fileSystems));
    extraOptions = [
      "--cap-drop=ALL"
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
      "--privileged"
    ];
  };

  # This is only for the nginx config of the downloader.
  modules.services.nginx.virtualHosts = {
    "shiro.lan" = {
      ssl = true;

      locations."/".proxyPass = "http://127.0.0.1:${toString config.shiro.ports.homarr}";
    };

    "dash.shiro.lan" = {
      ssl = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.dashdot}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
        '';
      };
    };
  };
}
