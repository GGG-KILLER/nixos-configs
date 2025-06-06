{ lib, config, ... }:
{
  config = lib.mkIf (!config.cost-saving.enable || !config.cost-saving.disable-hdds) {
    services.minio = {
      enable = true;
      region = "home-1";
      configDir = "/var/lib/minio";
      dataDir = [ "/storage/minio" ];
      rootCredentialsFile = config.age.secrets."minio.env".path;

      listenAddress = "127.0.0.1:${toString config.shiro.ports.minio}";
      consoleAddress = "127.0.0.1:${toString config.shiro.ports.minio-console}";
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
          proxyPass = "http://127.0.0.1:${toString config.shiro.ports.minio}";
          recommendedProxySettings = true;
          proxyWebsockets = true;

          extraConfig = ''
            proxy_connect_timeout 300;
            chunked_transfer_encoding off;
          '';
        };

        locations."~ ^/minio/ui/(.*)" = {
          proxyPass = "http://127.0.0.1:${toString config.shiro.ports.minio-console}/$1$is_args$args";
          recommendedProxySettings = true;
          proxyWebsockets = true;
          extraConfig = ''
            proxy_connect_timeout 300;
            chunked_transfer_encoding off;
          '';
        };
      };
    };
  };
}
