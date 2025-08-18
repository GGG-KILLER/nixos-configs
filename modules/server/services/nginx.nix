# Made by @Myaats adapted by me.
{
  inputs,
  options,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.nginx;
in
{
  options.modules.services.nginx =
    let
      vhost-opts = options.services.nginx.virtualHosts.type.getSubOptions [
        "modules"
        "services"
        "nginx"
        "virtualHosts"
      ];
    in
    {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable nginx service";
      };
      recommendedProxySettings = options.services.nginx.recommendedProxySettings // {
        default = true;
      };
      inherit (options.services.nginx) clientMaxBodySize proxyTimeout commonHttpConfig;

      virtualHosts = mkOption {
        type = types.attrsOf (
          types.submodule (
            { name, ... }:
            {
              options = {
                serverName = mkOption {
                  type = types.str;
                  default = name;
                };
                ssl = mkOption {
                  type = types.bool;
                  default = true;
                };

                inherit (vhost-opts)
                  listen
                  serverAliases
                  default
                  root
                  extraConfig
                  ;

                locations =
                  let
                    locationOptions =
                      recursiveUpdate
                        (import "${inputs.nixpkgs}/nixos/modules/services/web-servers/nginx/location-options.nix" {
                          inherit config lib;
                        })
                        {
                          options.sso = mkOption {
                            type = types.bool;
                            default = false;
                          };
                        };
                  in
                  mkOption {
                    type = with types; attrsOf (submodule locationOptions);
                    default = { };
                    example = literalExpression ''
                      {
                        "/" = {
                          proxyPass = "http://127.0.0.1:3000";
                        };
                      };
                    '';
                    description = lib.mdDoc "Declarative location config";
                  };
              };
            }
          )
        );
        default = { };
        description = "virtual hosts";
      };
    };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      enableReload = false;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      inherit (cfg) clientMaxBodySize proxyTimeout;

      commonHttpConfig =
        optionalString cfg.recommendedProxySettings ''
          proxy_connect_timeout   ${cfg.proxyTimeout};
          proxy_send_timeout      ${cfg.proxyTimeout};
          proxy_read_timeout      ${cfg.proxyTimeout};
          proxy_http_version      1.1;
          # don't let clients close the keep-alive connection to upstream. See the nginx blog for details:
          # https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives
          proxy_set_header        "Connection" "";

          proxy_set_header        Host $host;
          proxy_set_header        X-Real-IP $remote_addr;
          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header        X-Forwarded-Proto $scheme;
          proxy_set_header        X-Forwarded-Host $host;
          proxy_set_header        X-Forwarded-Server $host;
        ''
        + cfg.commonHttpConfig or "";

      virtualHosts = mapAttrs (
        key: server:
        mkMerge [
          {
            inherit (server)
              listen
              serverName
              serverAliases
              default
              ;

            locations = mapAttrs (
              host: loc:
              mkMerge [
                (filterAttrs (key: val: key != "sso") loc)
                (optionalAttrs loc.sso (throw "Not implemented."))
              ]
            ) server.locations;

            extraConfig = ''
              set_real_ip_from 127.0.0.0/8;
              real_ip_header proxy_protocol;
              ${optionalString (any (x: x.sso) (attrValues server.locations or { })) (throw "Not implemented.")}
              ${server.extraConfig}
            '';
          }
          (optionalAttrs (any (x: x.sso) (attrValues server.locations or { })) (throw "Not implemented."))
          (optionalAttrs (server.serverName != null && server.ssl) {
            enableACME = true;
            addSSL = true;
            http2 = true;
          })
          (optionalAttrs (server.root != null) { inherit (server) root; })
        ]
      ) cfg.virtualHosts;
    };

    security.acme = {
      acceptTerms = true; # kinda pointless since we never use upstream
      defaults = {
        server = "https://ca.lan/acme/acme/directory";
        renewInterval = "hourly";
      };
    };

    security.acme.certs = lib.mapAttrs' (
      name: server:
      lib.nameValuePair server.serverName {
        email = mkDefault "${server.serverName}@${config.networking.hostName}.lan";
      }
    ) (lib.filterAttrs (key: server: server.serverName != null && server.ssl) cfg.virtualHosts);

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      80
      443
    ];
  };
}
