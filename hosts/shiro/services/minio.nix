{config, ...}: {
  services.minio = {
    enable = true;
    region = "home-1";
    configDir = "/zfs-main-pool/data/minio/config";
    dataDir = ["/zfs-main-pool/data/minio/data"];
    rootCredentialsFile = config.age.secrets."minio.env".path;

    listenAddress = "127.0.0.1:8082";
    consoleAddress = "127.0.0.1:8083";
  };

  services.prometheus.exporters.minio = {
    enable = false;
    minioBucketStats = true;
    minioAddress = "http://localhost:8082";
  };

  modules.services.nginx = {
    virtualHosts."s3.shiro.lan" = {
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
        proxyPass = "http://localhost:8082";
        extraConfig = ''
          proxy_connect_timeout 300;

          chunked_transfer_encoding off;
        '';
      };

      locations."/minio/ui/" = {
        proxyPass = "http://localhost:8083";
        proxyWebsockets = true;
        extraConfig = ''
          rewrite ^/minio/ui/(.*) /$1 break;
          proxy_set_header X-NginX-Proxy true;

          # This is necessary to pass the correct IP to be hashed
          real_ip_header X-Real-IP;

          proxy_connect_timeout 300;

          proxy_set_header Origin ''';

          chunked_transfer_encoding off;
        '';
      };
    };
  };
}
