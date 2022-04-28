{ config, lib, pkgs, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
in
rec {
  my.networking.firefly-iii = {
    ipAddrs = {
      elan = "192.168.1.9";
      # clan = "192.168.2.13";
    };
    ports = [
      {
        protocol = "http";
        port = 80;
        description = "Local Nginx";
      }
    ];
  };

  containers.firefly-iii = mkContainer {
    name = "firefly-iii";

    includeAnimu = false;
    includeEtc = false;
    includeH = false;

    bindMounts = {
      "/var/www/firefly-iii" = {
        hostPath = "/zfs-main-pool/data/firefly-iii";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }:
      {
        services.phpfpm.pools.mypool = {
          user = "nobody";
          phpPackage = (pkgs.php.buildEnv {
            extensions = ({ enabled, all }: enabled ++ (with all;[
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
            ]));
          });
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

        services.nginx = {
          enable = true;
          virtualHosts."money.lan" = {
            default = true;
            root = "/var/www/firefly-iii/public";
            extraConfig = ''
              index index.html index.htm index.php;
            '';
            locations."/" = {
              tryFiles = "$uri /index.php$is_args$args";
              extraConfig = ''
                autoindex on;
                sendfile off;
              '';
            };
            locations."~ \\.php$".extraConfig = ''
              fastcgi_pass  unix:${config.services.phpfpm.pools.mypool.socket};
              fastcgi_index index.php;
              fastcgi_read_timeout 240;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_split_path_info ^(.+.php)(/.+)$;
            '';
          };
        };
      };
  };
}
