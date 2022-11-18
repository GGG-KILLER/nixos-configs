{
  config,
  lib,
  pkgs,
  ...
} @ args:
with lib; {
  modules.containers.firefly-iii = {
    hostBridge = "br-ctlan";
    localAddress = "172.16.0.4/24";

    bindMounts = {
      "/var/www/firefly-iii" = {
        hostPath = "/zfs-main-pool/data/firefly-iii";
        isReadOnly = false;
      };
      "/var/www/firefly-iii-data-importer" = {
        hostPath = "/zfs-main-pool/data/firefly-iii-data-importer";
        isReadOnly = false;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      networking = {
        defaultGateway = "172.16.0.1";
        nameservers = ["192.168.1.1"];
      };

      i18n.supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "pt_BR.UTF-8/UTF-8"
      ];

      services.phpfpm.pools.firefly-iii = {
        user = config.services.nginx.user;
        group = config.services.nginx.group;
        phpPackage = pkgs.php.buildEnv {
          extensions = {
            enabled,
            all,
          }:
            enabled
            ++ (with all; [
              bcmath
              intl
              curl
              zip
              sodium
              gd
              xml
              mbstring
              pgsql
              pdo_pgsql
            ]);
        };
        settings = {
          "pm" = "dynamic";
          "listen.owner" = config.services.nginx.user;
          "pm.max_children" = 5;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 1;
          "pm.max_spare_servers" = 3;
          "pm.max_requests" = 500;
        };
      };

      services.phpfpm.pools.firefly-iii-data-importer = {
        user = config.services.nginx.user;
        group = config.services.nginx.group;
        phpPackage = pkgs.php.buildEnv {
          extensions = {
            enabled,
            all,
          }:
            enabled
            ++ (with all; [
              bcmath
            ]);
        };
        settings = {
          "pm" = "dynamic";
          "listen.owner" = config.services.nginx.user;
          "pm.max_children" = 5;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 1;
          "pm.max_spare_servers" = 3;
          "pm.max_requests" = 500;
        };
      };

      modules.services.nginx = {
        enable = true;
        virtualHosts."money.lan" = {
          ssl = false;
          root = "/var/www/firefly-iii/public";
          extraConfig = ''
            set_real_ip_from 172.16.0.0/24;

            fastcgi_param HTTP_PROXY "";
            index index.html index.htm index.php;
          '';
          locations."/" = {
            tryFiles = "$uri /index.php$is_args$args";
          };
          locations."~ \\.php$".extraConfig = ''
            fastcgi_pass  unix:${config.services.phpfpm.pools.firefly-iii.socket};
            fastcgi_index index.php;
            fastcgi_read_timeout 240;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

            fastcgi_param  QUERY_STRING       $query_string;
            fastcgi_param  REQUEST_METHOD     $request_method;
            fastcgi_param  CONTENT_TYPE       $content_type;
            fastcgi_param  CONTENT_LENGTH     $content_length;

            fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
            fastcgi_param  REQUEST_URI        $request_uri;
            fastcgi_param  DOCUMENT_URI       $document_uri;
            fastcgi_param  DOCUMENT_ROOT      $document_root;
            fastcgi_param  SERVER_PROTOCOL    $server_protocol;
            fastcgi_param  REQUEST_SCHEME     $scheme;
            fastcgi_param  HTTPS              $https if_not_empty;

            fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
            fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

            fastcgi_param  REMOTE_ADDR        $remote_addr;
            fastcgi_param  REMOTE_PORT        $remote_port;
            fastcgi_param  SERVER_ADDR        $server_addr;
            fastcgi_param  SERVER_PORT        $server_port;
            fastcgi_param  SERVER_NAME        $server_name;

            # PHP only, required if PHP was built with --enable-force-cgi-redirect
            fastcgi_param  REDIRECT_STATUS    200;

            fastcgi_split_path_info ^(.+.php)(/.+)$;
            fastcgi_buffers 16 32k;
            fastcgi_buffer_size 64k;
            fastcgi_busy_buffers_size 64k;
          '';
        };
        virtualHosts."importer.money.lan" = {
          ssl = false;
          root = "/var/www/firefly-iii-data-importer/public";
          extraConfig = ''
            set_real_ip_from 172.16.0.0/24;

            fastcgi_param HTTP_PROXY "";
            index index.html index.htm index.php;
          '';
          locations."/" = {
            tryFiles = "$uri /index.php$is_args$args";
          };
          locations."~ \\.php$".extraConfig = ''
            fastcgi_pass  unix:${config.services.phpfpm.pools.firefly-iii-data-importer.socket};
            fastcgi_index index.php;
            fastcgi_read_timeout 240;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

            fastcgi_param  QUERY_STRING       $query_string;
            fastcgi_param  REQUEST_METHOD     $request_method;
            fastcgi_param  CONTENT_TYPE       $content_type;
            fastcgi_param  CONTENT_LENGTH     $content_length;

            fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
            fastcgi_param  REQUEST_URI        $request_uri;
            fastcgi_param  DOCUMENT_URI       $document_uri;
            fastcgi_param  DOCUMENT_ROOT      $document_root;
            fastcgi_param  SERVER_PROTOCOL    $server_protocol;
            fastcgi_param  REQUEST_SCHEME     $scheme;
            fastcgi_param  HTTPS              $https if_not_empty;

            fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
            fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

            fastcgi_param  REMOTE_ADDR        $remote_addr;
            fastcgi_param  REMOTE_PORT        $remote_port;
            fastcgi_param  SERVER_ADDR        $server_addr;
            fastcgi_param  SERVER_PORT        $server_port;
            fastcgi_param  SERVER_NAME        $server_name;

            # PHP only, required if PHP was built with --enable-force-cgi-redirect
            fastcgi_param  REDIRECT_STATUS    200;

            fastcgi_split_path_info ^(.+.php)(/.+)$;
            fastcgi_buffers 16 32k;
            fastcgi_buffer_size 64k;
            fastcgi_busy_buffers_size 64k;
          '';
        };
      };
    };
  };
}
