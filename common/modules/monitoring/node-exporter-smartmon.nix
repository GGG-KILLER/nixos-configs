{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.node-exporter-smartmon;
in {
  options.modules.services.node-exporter-smartmon = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the smartmon node_exporter helper.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.prometheus.enable && config.services.prometheus.exporters.node.enable;
        message = "Prometheus and node_exporter must be enabled for smartmon node_exporter to be enabled.";
      }
    ];

    # Set up the timer to run the smartmon text file generator.
    systemd.timers.prometheus-node-exporter-smartmon = {
      enable = true;
      description = "Update smartmon data";
      wantedBy = ["timers.target"];
      partOf = ["prometheus-node-exporter.service"];
      timerConfig = {
        OnCalendar = "*:*";
        Unit = "prometheus-node-exporter-smartmon.service";
        Persistent = "yes";
      };
    };

    # Set up the smartmon text file generator service.
    systemd.services.prometheus-node-exporter-smartmon = {
      enable = true;
      path = with pkgs; [bash gawk moreutils smartmontools];
      serviceConfig = {
        Type = "oneshot";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
      };
      script = let
        script = pkgs.writeScript "smartmon.sh" (builtins.readFile ./smartmon.sh);
      in ''
        mkdir -pm 0775 /var/lib/prometheus/node-exporter/text-files
        set -euxo pipefail
        ${script} | sponge /var/lib/prometheus/node-exporter/text-files/smartmon.prom
      '';
    };

    # Add the text file flags to the node exporter config.
    services.prometheus.exporters.node = {
      enabledCollectors = ["textfile"];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/prometheus/node-exporter/text-files"
      ];
    };
  };
}
