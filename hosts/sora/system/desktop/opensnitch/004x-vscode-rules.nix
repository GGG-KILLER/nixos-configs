{
  lib,
  pkgs,
  config,
  ...
}:
let
  base = 40;
  getSeq = num: lib.fixedWidthNumber 4 (base + num);
in
{
  services.opensnitch.rules."${getSeq 0}-vscode-allow-network" = {
    name = "${getSeq 0}-vscode-allow-network";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    action = "allow";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "dest.port";
          data = "443";
        }
        {
          type = "simple";
          operand = "user.id";
          data = toString config.users.users.ggg.uid;
        }
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.vscode}/lib/vscode/code";
        }
        {
          type = "regexp";
          operand = "dest.host";
          data = "^(${
            lib.concatStringsSep "|" (
              map lib.escapeRegex [
                "main.vscode-cdn.net"
                "api.github.com"
                "www.gravatar.com"
                "avatars.githubusercontent.com"
                "main.vscode-cdn.net"
                "api.github.com"
              ]
            )
          })$";
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 1}-vscode-block-telemetry" = {
    name = "${getSeq 1}-vscode-block-telemetry";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    action = "reject";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.vscode}/lib/vscode/code";
        }
        {
          type = "regexp";
          operand = "dest.host";
          data = "^(${
            lib.concatStringsSep "|" (
              map lib.escapeRegex [
                "configs.gitkraken.dev"
                "education.github.com"
              ]
            )
          })$";
        }
      ];
    };
  };
}
