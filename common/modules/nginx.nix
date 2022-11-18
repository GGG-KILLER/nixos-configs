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
    nginx-opts = options.services.nginx.type.getSubOptions {};
  in {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable nginx service";
    };
    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule
        {name, ...}: {
          options = {
            serverName = mkOption {
              type = types.str;
              default = name;
            };
            serverAliases = mkOption {
              type = types.listOf types.str;
              default = [];
            };
            default = mkOption {
              type = types.bool;
              default = false;
            };
            ssl = mkOption {
              type = types.bool;
              default = true;
            };
            root = mkOption {
              type = types.nullOr types.path;
              default = null;
            };
            extraConfig = mkOption {
              type = types.lines;
              default = "";
            };
            locations = mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  priority = mkOption {
                    type = types.int;
                    default = 1000;
                  };
                  proxyPass = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                  extraConfig = mkOption {
                    type = types.lines;
                    default = null;
                  };
                };
              });
              default = {};
            };
          };
        });
      default = {};
      description = "virtual hosts";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      enableReload = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      virtualHosts =
        lib.attrsets.mapAttrs
        (key: server:
          {
            serverName = server.serverName;
            serverAliases = server.serverAliases;
            default = server.default;
            locations = server.locations;
            extraConfig = ''
              set_real_ip_from 127.0.0.0/8;
              real_ip_header proxy_protocol;
              ${server.extraConfig}
            '';
            listen =
              [
                {
                  addr = "0.0.0.0";
                  port = 80;
                }
              ]
              ++ (optional (server.serverName != null && server.ssl) [
                # Needed for SNI Proxy
                {
                  addr = "0.0.0.0";
                  port = 444;
                  ssl = server.ssl;
                  extraParameters = ["proxy_protocol"];
                }
              ]);
          }
          // (optionalAttrs (server.serverName != null && server.ssl) {
            forceSSL = true;
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
