{ lib, config, ... }:
{
  options.ggg.dns-cache.enable = lib.mkEnableOption "local caching DNS resolver (systemd-resolved)";

  config = lib.mkIf config.ggg.dns-cache.enable {
    services.resolved = {
      enable = true;
      dnssec = "false";
      settings.Resolve.Cache = "yes";
      settings.Resolve.CacheFromLocalhost = "no";
    };
  };
}
