# I do not know where this was originally obtained from but @myaats was the one who provided it to me.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.smartmon-exporter;

  smartmontools-exporter = pkgs.writeShellApplication {
    name = "smartmontools-exporter";

    inheritPath = false;
    runtimeInputs = with pkgs; [
      gawk
      moreutils
      smartmontools
    ];

    text = builtins.readFile ./smartmon.sh;
  };
in
{
  options.modules.services.smartmon-exporter = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the smartmon node_exporter helper.";
    };
    listen-addr = mkOption {
      type = types.str;
      default = "/run/smartmontools-exporter.sock";
      description = "The address or UNIX socket path to listen on.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.prometheus.enable && config.services.prometheus.exporters.node.enable;
        message = "Prometheus and node_exporter must be enabled for smartmon node_exporter to be enabled.";
      }
    ];

    environment.systemPackages = [ smartmontools-exporter ];

    systemd.sockets.smartmontools-exporter = {
      enable = true;
      description = "The smartmontools exporter that returns smartctl information about all disks.";

      socketConfig = {
        ListenStream = cfg.listen-addr;
        Accept = true;
        RemoveOnStop = true;
      };
    };

    systemd.services.smartmontools-exporter = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";

        StandardInput = "socket";
        StandardOutput = "socket";

        PrivateTmp = true;
        WorkingDirectory = "/tmp";
      };

      path = [
        pkgs.coreutils
        smartmontools-exporter
      ];
      script = ''
        #!${pkgs.runtimeShell}
        set -euo pipefail

        {
        cat <<HTTP | tr '\n' '\r\n'
        HTTP/1.1 200 OK
        Server: bash
        Date: $(date --rfc-email)
        Content-Type: text/plain; version=0.0.4; charset=utf-8; escaping=underscores
        Cache-Control: no-store
        X-Content-Type-Options: nosniff
        X-Frame-Options: deny
        X-Xss-Protection: 1; mode=block

        HTTP

        smartmontools-exporter
        } | tr '\n' '\r\n'
      '';
    };
  };
}
