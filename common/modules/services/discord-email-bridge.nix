{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.discord-email-bridge;
in
{
  options.modules.services.discord-email-bridge = {
    enable = mkEnableOption "Whether to enable the DiscordEmailBridge service";
    serverName = mkOption {
      type = types.str;
      description = "The server name for the SMTP server";
    };
    port = mkOption {
      type = types.port;
      description = "The port for the SMTP server";
    };
  };
}
