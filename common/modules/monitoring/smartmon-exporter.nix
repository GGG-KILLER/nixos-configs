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
      coreutils
      gawk
      gnugrep
      gnused
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
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The IP address to listen on.";
    };
    port = mkOption {
      type = types.port;
      default = 9090;
      description = "The port to listen on.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ smartmontools-exporter ];

    systemd.services.smartmontools-exporter =
      let
        response-script = pkgs.writeShellScript "generate-smartmon-exporter-response" ''
          cat <<HEADERS
          HTTP/1.1 200 OK
          Date: $(date)
          Server: netcat
          Content-Type: text/plain; version=0.0.4; charset=utf-8; escaping=underscores

          HEADERS

          smartmontools-exporter
        '';
      in
      {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        path = [
          pkgs.coreutils # cat tr
          smartmontools-exporter
        ];

        serviceConfig = {
          ExecStart = "${lib.getExe' pkgs.nmap "ncat"} --listen ${lib.escapeShellArg cfg.addr} ${lib.escapeShellArg cfg.port} --keep-open --nodns --exec ${lib.escapeShellArg response-script}";

          PrivateTmp = true;
          WorkingDirectory = "/tmp";
        };
      };
  };
}
