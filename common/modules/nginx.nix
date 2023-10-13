# Made by @Myaats adapted by me.
{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.nginx;
in {
  options.modules.services.nginx = let
    vhost-opts = options.services.nginx.virtualHosts.type.getSubOptions ["modules" "services" "nginx" "virtualHosts"];
  in {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable nginx service";
    };
    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          serverName = mkOption {
            type = types.str;
            default = name;
          };
          ssl = mkOption {
            type = types.bool;
            default = true;
          };

          inherit (vhost-opts) serverAliases default root extraConfig locations;
        };
      }));
      default = {};
      description = "virtual hosts";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      enableReload = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedZstdSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      virtualHosts =
        lib.attrsets.mapAttrs
        (key: server:
          {
            inherit (server) serverName serverAliases default locations;
            extraConfig = ''
              set_real_ip_from 127.0.0.0/8;
              real_ip_header proxy_protocol;
              ${server.extraConfig}
            '';
          }
          // (optionalAttrs (server.serverName != null && server.ssl) {
            enableACME = true;
            addSSL = true;
            http2 = true;
          })
          // (optionalAttrs (server.root != null) {
            root = server.root;
          }))
        cfg.virtualHosts;
    };

    security.acme = {
      acceptTerms = true; # kinda pointless since we never use upstream
      defaults = {
        server = "https://ca.lan/acme/acme/directory";
        renewInterval = "hourly";
      };
    };

    security.acme.certs =
      lib.mapAttrs'
      (name: server: lib.nameValuePair server.serverName {email = "${server.serverName}@${config.networking.hostName}.lan";})
      (lib.filterAttrs (key: server: server.serverName != null && server.ssl) cfg.virtualHosts);

    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [80 443];
  };
}
