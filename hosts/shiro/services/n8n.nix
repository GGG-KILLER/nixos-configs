{
  lib,
  pkgs,
  config,
  ...
}:
let
  npm = lib.getExe' pkgs.nodejs "npm";
  n8n = pkgs.n8n.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [ ./n8n.patch ];
  });

  preStart = pkgs.writeShellScript "n8n-pre-start.sh" ''
    set -euo pipefail

    mkdir -p "$N8N_USER_FOLDER"/.n8n/nodes
    pushd "$N8N_USER_FOLDER"/.n8n/nodes
      ${npm} install -y ${
        lib.escapeShellArgs [
          "@jordanburke/n8n-nodes-discord"
        ]
      }
    popd
  '';
in
{
  services.n8n.enable = true;
  services.n8n.webhookUrl = "https://n8n.ggg.dev/";
  services.n8n.settings.port = config.shiro.ports.n8n;

  systemd.services.n8n.serviceConfig.LoadCredential = [
    "encryption_key:${config.age.secrets.n8n-encryption-key.path}"
    "pgsql_password:${config.age.secrets.n8n-pgsql-password.path}"
  ];
  systemd.services.n8n.serviceConfig.ExecStartPre = preStart;
  systemd.services.n8n.serviceConfig.ExecStart = lib.mkForce "${n8n}/bin/n8n";
  systemd.services.n8n.environment = {
    NODE_ENV = "production";
    GENERIC_TIMEZONE = config.time.timeZone;

    N8N_EDITOR_BASE_URL = "https://n8n.shiro.lan/";
    N8N_ENCRYPTION_KEY_FILE = "%d/encryption_key";
    N8N_HOST = "n8n.shiro.lan";
    N8N_PORT = toString config.shiro.ports.n8n;
    N8N_HIRING_BANNER_ENABLED = "false";

    N8N_PUBLIC_API_DISABLED = "false";
    N8N_PUBLIC_API_SWAGGERUI_DISABLED = "true";

    N8N_METRICS = "true";
    N8N_METRICS_INCLUDE_MESSAGE_EVENT_BUS_METRICS = "true";
    N8N_METRICS_INCLUDE_WORKFLOW_ID_LABEL = "true";
    N8N_METRICS_INCLUDE_NODE_TYPE_LABEL = "true";

    NODE_FUNCTION_ALLOW_BUILTIN = "*";
    NODE_FUNCTION_ALLOW_EXTERNAL = "moment,lodash";

    DB_TYPE = "postgresdb";
    DB_POSTGRESDB_DATABASE = "n8n-db";
    DB_POSTGRESDB_HOST = "pgprd.shiro.lan";
    DB_POSTGRESDB_USER = "n8n-user";
    DB_POSTGRESDB_PASSWORD_FILE = "%d/pgsql_password";

    # Isolation
    N8N_DIAGNOSTICS_ENABLED = "false";
    N8N_VERSION_NOTIFICATIONS_ENABLED = "false";
    N8N_TEMPLATES_ENABLED = "false";
    EXTERNAL_FRONTEND_HOOKS_URLS = "";
    N8N_DIAGNOSTICS_CONFIG_FRONTEND = "";
    N8N_DIAGNOSTICS_CONFIG_BACKEND = "";
  };

  modules.services.nginx.virtualHosts."n8n.shiro.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.shiro.ports.n8n}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  services.cloudflared.tunnels."3c1b8ea8-a43d-4a97-872c-37752de30b3f".ingress."n8n.ggg.dev" = {
    originRequest.httpHostHeader = "n8n.shiro.lan";
    originRequest.originServerName = "n8n.shiro.lan";

    # path = "^/api/";
    service = "https://127.0.0.1";
  };
}
