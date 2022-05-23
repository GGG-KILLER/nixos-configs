{ config, lib, pkgs, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
in
rec {
  my.networking.home-assistant = {
    ipAddrs = {
      elan = "192.168.1.13";
      # clan = "192.168.2.13";
    };
    ports = [
      {
        protocol = "http";
        port = 8123;
        description = "Home Assistant Web UI";
      }
      {
        protocol = "http";
        port = 6052;
        description = "ESPHome Web UI";
      }
      {
        protocol = "http";
        port = 80;
        description = "Local Nginx";
      }
    ];
  };

  containers.home-assistant = mkContainer {
    name = "home-assistant";

    includeAnimu = false;
    includeEtc = false;
    includeH = false;

    bindMounts = {
      "/var/lib/hass" = {
        hostPath = "/zfs-main-pool/data/home-assistant";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }:
      {
        services.home-assistant = {
          enable = true;
          package = (pkgs.home-assistant.override {
            extraPackages = python3Packages: with python3Packages; [
            ];
            extraComponents = [
              "default_config"
              "esphome"
              "speedtestdotnet"
            ];
          }).overrideAttrs (oldAttrs: {
            # Don't run package tests, they take a long time
            doInstallCheck = false;
          });
          configWritable = true;
          config = {
            default_config = { };
            # HTTP confs
            http = {
              trusted_proxies = [ "127.0.0.1" ];
              use_x_forwarded_for = true;
            };
            # Enable the frontend
            frontend = { };
            mobile_app = { };
            # ESPHome
            esphome = { };
            # Speedtest.net
            speedtestdotnet = { };
          };
        };

        systemd.services.esphome = {
          description = "ESPHome";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = "hass";
            Group = "hass";
            Restart = "on-failure";
            WorkingDirectory = config.services.home-assistant.configDir;
            ExecStart = "${pkgs.esphome}/bin/esphome dashboard ${config.services.home-assistant.configDir}/esphome";
          };
        };

        services.nginx = {
          enable = true;
          virtualHosts."hass.lan" = {
            rejectSSL = true;
            locations."/" = {
              extraConfig = ''
                proxy_pass http://localhost:8123;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Protocol $scheme;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_read_timeout 6h;
              '';
            };
          };
          virtualHosts."esphome.lan" = {
            rejectSSL = true;
            locations."/" = {
              extraConfig = ''
                proxy_pass http://localhost:6052;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Protocol $scheme;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_read_timeout 6h;
              '';
            };
          };
        };
      };
  };
}
