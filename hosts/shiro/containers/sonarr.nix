{
  config,
  lib,
  ...
} @ args:
with lib; {
  modules.containers.sonarr = {
    vpn = true;

    hostBridge = "br-ctvpn";
    localAddress = "10.11.0.4/10";

    builtinMounts = {
      animu = true;
      series = true;
      etc = true;
      h = true;
    };

    bindMounts = {
      "/mnt/sonarr" = {
        hostPath = "/zfs-main-pool/data/sonarr";
        isReadOnly = false;
      };
      "/mnt/jackett" = {
        hostPath = "/zfs-main-pool/data/jackett";
        isReadOnly = false;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      networking = {
        defaultGateway = "10.11.0.1";
        nameservers = ["10.11.0.1"];
        useHostResolvConf = false;
      };

      # Sonarr
      services.sonarr = {
        enable = true;
        openFirewall = true;
        user = "my-sonarr";
        group = "data-members";
        dataDir = "/mnt/sonarr";
      };

      # Jackett
      services.jackett = {
        enable = true;
        openFirewall = true;
        user = "my-sonarr";
        group = "data-members";
        dataDir = "/mnt/jackett";
      };

      # NGINX
      modules.services.nginx = {
        enable = true;
        virtualHosts = {
          "sonarr.lan" = {
            ssl = false;
            extraConfig = ''
              set_real_ip_from 10.11.0.0/24;
            '';
            locations."/".proxyPass = "http://localhost:8989";
          };
          "jackett.lan" = {
            ssl = false;
            extraConfig = ''
              set_real_ip_from 10.11.0.0/24;
            '';
            locations."/".proxyPass = "http://localhost:9117";
          };
        };
      };
    };
  };
}
