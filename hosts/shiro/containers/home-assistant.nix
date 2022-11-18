{
  config,
  lib,
  pkgs,
  ...
} @ args:
with lib; let
  consts = config.my.constants;
in rec {
  my.networking.home-assistant = {
    mainAddr = "10.0.0.5";
    extraNames = [
      "hass"
      "esphome"
    ];
    ports = [
      {
        protocol = "http";
        port = 80;
        description = "Local NGINX";
      }
    ];
  };

  modules.containers.home-assistant = {
    bindMounts = {
      "/var/lib/hass" = {
        hostPath = "/zfs-main-pool/data/home-assistant";
        isReadOnly = false;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      services.home-assistant = {
        enable = true;
        package =
          (pkgs.home-assistant.override {
            extraPackages = python3Packages:
              with python3Packages; [
              ];
            extraComponents = [
              "default_config"
              "esphome"
              "speedtestdotnet"
            ];
          })
          .overrideAttrs (oldAttrs: {
            # Don't run package tests, they take a long time
            doInstallCheck = false;
          });
        configWritable = true;
        config = {
          default_config = {};
          # HTTP confs
          http = {
            trusted_proxies = ["127.0.0.1"];
            use_x_forwarded_for = true;
          };
          # Enable the frontend
          frontend = {};
          mobile_app = {};
          # ESPHome
          esphome = {};
          # Speedtest.net
          speedtestdotnet = {};
        };
      };

      systemd.services.esphome = {
        description = "ESPHome";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          User = "hass";
          Group = "hass";
          Restart = "on-failure";
          WorkingDirectory = config.services.home-assistant.configDir;
          ExecStart = "${pkgs.esphome}/bin/esphome dashboard ${config.services.home-assistant.configDir}/esphome";
        };
      };

      modules.services.nginx = {
        enable = true;
        virtualHosts."hass.lan" = {
          ssl = false;
          extraConfig = ''
            set_real_ip_from 10.0.0.0/24;
          '';
          locations."/" = {
            proxyPass = "http://localhost:8123";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 6h;
            '';
          };
        };
        virtualHosts."esphome.lan" = {
          ssl = false;
          extraConfig = ''
            set_real_ip_from 10.0.0.0/24;
          '';
          locations."/" = {
            proxyPass = "http://localhost:6052";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 6h;
            '';
          };
        };
      };
    };
  };
}
